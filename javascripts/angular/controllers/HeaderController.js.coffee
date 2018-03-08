@bestfrent.controller 'HeaderController', ["$scope", "$rootScope", "Facebook", "Authenticate","Notification","Property", "$location", "$translate", "$cookies"
($scope, $rootScope, Facebook, Authenticate, Notification, Property, $location, $translate, $cookies)->
  $rootScope.userLoggedIn = Authenticate.isLoggedIn
  $rootScope.user_register = true
  $rootScope.conversationOpen = false
  $rootScope.tenantConversationOpen = false
  $rootScope.lang=''
  # Notification.messageCount()

  if $rootScope.currentUser
    $rootScope.user_register = $rootScope.currentUser.registered_user
    if $rootScope.my_notification is undefined
      Notification.myNotification()

  $scope.$watch (->
    Facebook.isReady()
  ), (newVal) ->
    $scope.facebookReady = true
    return

  if $rootScope.currentUser && $rootScope.currentUser != "null" &&  $rootScope.currentUser != null
    PrivatePub.subscribe "/update_notification_#{currentUser.id}", (data, channel) ->
      Notification.myNotification()

  $rootScope.signInUser = ()->
    jQuery("#signinModal").modal("show")
    jQuery("#signinModal").parent().show()
    $rootScope.error = false
    false

  $rootScope.deleteAccount = () ->
    jQuery("#deleteAccountModal").modal("show")
    jQuery("#deleteAccountModal").parent().show()
    $rootScope.error = false
    false

  $rootScope.signInNormal = (user)->
    Authenticate.signIn(user)

  $rootScope.signOutUser = ()->
    Authenticate.signOut()

  $rootScope.language = ()->
    $rootScope.lang=navigator.language || navigator.userLanguage
    $rootScope.lang1=$rootScope.lang.substring(0,$rootScope.lang.indexOf("-"))
    if $rootScope.lang == "de" ||  $rootScope.lang == "de-DE" ||  $rootScope.lang == "de_DE"
      $translate.use $cookies.myLanguage = "gr"
    else
      $translate.use $cookies.myLanguage = "en"
   	
  $rootScope.closeSignInModal = () ->
    jQuery("#close_sign_in_model").click()
    jQuery("body").removeClass("modal-open")
    jQuery(".modal-backdrop").removeClass("in").addClass("out")

  $rootScope.initFacebookLogin = ()->
    Facebook.getLoginStatus (response)->
      if response.status == "connected"
        $scope.authenticateUser(response.authResponse)
      else
        Facebook.login((response)->
          response
        ,{scope: 'user_online_presence,email,user_about_me,friends_about_me,user_birthday,publish_actions,publish_stream'}
        )
    return


  $rootScope.authNetwork = (network) ->
    openUrl = '/users/auth/' + network;
    window.$windowScope = $scope;
    window.open openUrl, "Authenticate Account", "width=500, height=500"
    return true

  $rootScope.handlePopupAuthentication = (user) ->
    #Note: using $scope.$apply wrapping
    #the window popup will call this
    #and is unwatched func
    #so we need to wrap
    $rootScope.$apply ->
      $scope.applyNetwork user

  $scope.applyNetwork=(user) ->
    console.log(user)
    window.location.reload()

  $scope.$on 'Facebook:statusChange', (ev, response)->
    if response.status == "connected"
      $scope.authenticateUser(response.authResponse)

  $scope.$watch (->
    Facebook.isReady()
  ), (newVal) ->
    $scope.facebookReady = true
    return


  $scope.authenticateUser = (auth)->
    _params = {signup_type: "facebook"}
    _params.services_attributes = {provider: "facebook", uid: auth.userID, auth_key: auth.accessToken}
    Facebook.api("/me", (response)->
      _params.email = response.email
      _params.first_name = response.first_name
      _params.last_name = response.last_name
      _params.username = response.username
      _params.dob = response.birthday
      _params.gender = response.gender
      _params.city = response.location.name
      Authenticate.signUp(_params)
    , {scope: 'user_online_presence,email,user_about_me,friends_about_me,user_birthday,publish_actions,publish_stream'})

  $scope.$on 'user:signedIn', (ev, response)->
    $rootScope.userLoggedIn = response.success
    $rootScope.currentUser = response.user
    Authenticate.currentUser = response.user
    if $rootScope.currentUser
      $rootScope.user_register = $rootScope.currentUser.registered_user
      $rootScope.user_register = response.user.registered_user
      $translate.use $.cookie("myLanguage")
    if response.success == true
      Authenticate.isLoggedIn = true
      $translate.use $.cookie("myLanguage")
      window.location.reload()
      return false
      jQuery("#signinModal").modal("hide")
      jQuery("#signinModal").parent().hide()
      jQuery(".modal-backdrop.fade.in").remove()
    else
      $rootScope.error = response.error
    false

  $scope.$on 'message:count', (ev, response)->
    if response.success
      $scope.userMessage = response.total

  $scope.$on 'user:signOut', (ev, response)->
    Authenticate.isLoggedIn = false
    $rootScope.userLoggedIn = false
    Authenticate.currentUser = null
    $rootScope.currentUser = null
    window.location.reload()
    return false

  $rootScope.openNoticePopup = (data_hash) ->
    $rootScope.notice = data_hash
    $rootScope.notice_modal_popup = "open"

  $rootScope.closeNoticePopup = () ->
    $rootScope.notice = {title: "", message: "", bttn_text: ""}
    $rootScope.notice_modal_popup = "close"




  $rootScope.conversationMsg = (obj, selectedProperty) ->
    message = obj
    msg = ""
    try
      if message.message_type

        if message.message_type.hasOwnProperty('uploaded') and message.message_type.is_uploaded
          msg = $translate.instant('MESSAGE.TENANT_DOC_UPLOADED_MESSAGE') + " <a href='/api/documents/download_doc?tenant=" + message.user_id + "&type=" + message.message_type.uploaded + "&property=" + message.message_type.property_id + "' target='_blank'>" + $translate.instant('MESSAGE.'+message.message_type.uploaded) + "</a>" + ". " + $translate.instant('MESSAGE.TENANT_DOC_UPLOAD_MESSAGE_SUFIX')

        else if message.message_type.hasOwnProperty('uploaded') && !message.message_type.is_uploaded
          msg = $translate.instant('MESSAGE.TENANT_DOC_UPDATED_MESSAGE') + " <a href='/api/documents/download_doc?tenant=" + message.user_id + "&type=" + "message.message_type.uploaded" + "&property=" + message.message_type.property_id + "' target='_blank'>" + $translate.instant('MESSAGE.'+message.message_type.uploaded) + "</a>" + ". " + $translate.instant('MESSAGE.TENANT_DOC_UPLOAD_MESSAGE_SUFIX')
        else if message.message_type.hasOwnProperty('change_requirement')
          msg = $translate.instant('MESSAGE.'+message.message_type.change_requirement)
        else if message.message_type.hasOwnProperty('missing_doc')
          msg = $translate.instant('MESSAGE.LANDLORD_REQUEST_FOR_MISSING_DOC_MESSAGE') + $translate.instant('MESSAGE.DOC_REQUIRE.'+message.message_type.missing_doc) + ". " + $translate.instant('MESSAGE.LANDLORD_MESSAGE_SUFIX') + message.body
        else if message.message_type.hasOwnProperty('tenant_confirm')
          msg = $translate.instant('MESSAGE.TENANT_CONFIRM_MSG') + " " + selectedProperty.title + ' ' + selectedProperty.address.street + ". " + message.body
        else if (message.message_type and message.message_type.hasOwnProperty('message_type'))
          if(message.message_type.message_type == 'contract_update' )
            msg = $translate.instant('MESSAGE.CONTRACT.UPDATE') + " <a href='/api/contracts/download?property_id=" + message.message_type.property_id + "' target='_blank'>" + $translate.instant('MESSAGE.CONTRACT.LINK_TXT') + "</a>" + "."
          else if(message.message_type.message_type == 'contract_upload' )
            msg = $translate.instant('MESSAGE.CONTRACT.UPLOAD') + " <a href='/api/contracts/download?property_id=" + message.message_type.property_id + "' target='_blank'>" + $translate.instant('MESSAGE.CONTRACT.LINK_TXT') + "</a>."
          else if(message.message_type.message_type == 'contract_delete' )
            msg = $translate.instant('MESSAGE.CONTRACT.DELETE')
          else if(message.message_type.message_type == 'update_sign_contract' )
            msg = $translate.instant('MESSAGE.SIGN_CONTRACT.UPDATE') + " <a href='/api/contracts/download?property_id=" + message.message_type.property_id + "&type=signed' target='_blank'>" + $translate.instant('MESSAGE.SIGN_CONTRACT.LINK_TXT') + "</a>."
          else if(message.message_type.message_type == 'upload_sign_contract' )
            msg = $translate.instant('MESSAGE.SIGN_CONTRACT.UPLOAD') + " <a href='/api/contracts/download?property_id=" + message.message_type.property_id + "&type=signed' target='_blank'>" + $translate.instant('MESSAGE.CONTRACT.LINK_TXT') + "</a>."
          else if(message.message_type.message_type == 'delete_sign_contract' )
            msg = $translate.instant('MESSAGE.SIGN_CONTRACT.DELETE')
          else if(message.message_type.message_type == 'payment' )
            msg = $translate.instant('MESSAGE.PAYMENT.PAYRENT') + message.body
          else if(message.message_type.message_type == 'edit_payment' )
            msg = $translate.instant('MESSAGE.PAYMENT.EDIT_PAYRENT') + message.body
          else if(message.message_type.message_type == 'stop_payment' )
            msg = $translate.instant('MESSAGE.PAYMENT.STOP_PAYRENT') + message.body
          else if(message.message_type.message_type == 'accept_payment' )
            msg = $translate.instant('MESSAGE.PAYMENT.ACCEPT') + message.body
          else if(message.message_type.message_type == 'decline_payment' )
            msg = $translate.instant('MESSAGE.PAYMENT.DECLINE') + message.body
          else
            msg = $translate.instant(message.message_type.message_type,{msg_body: message.body})
      else
        msg = message.body
    catch e
      console.log e
    return msg



]
