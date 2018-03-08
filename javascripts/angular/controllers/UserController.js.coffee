userController = angular.module('UserController',  ['ui.bootstrap','angular-flexslider', 'pascalprecht.translate', 'ngCookies'])

userController.controller "UserController", ['$scope', '$routeParams','$location', 'Authenticate', '$rootScope', '$translate', '$cookieStore', 'Premium'
  ($scope, $routeParams, $location, Authenticate, $rootScope, $translate, $cookieStore, Premium)->
    $scope.user = $rootScope.currentUser
    $scope.userTemplate = {}
    $scope.userErrors = []
    $scope.deleteAccountReason = {}
    $scope.changePassword = false
    $rootScope.conversationOpen = false
    $rootScope.tenantConversationOpen = false
    $scope.userTemplate.url = "user/index.html"

    $scope.userProfileCompletion = $rootScope.currentUser
    $scope.profileComplition =() ->
      count = 0
      countable_values = ["dob", "gender", "job", "title", "annual_income", "company", "residence", "no_of_children", "status", "education", "lang_known", "reason_for_moving", "about_me", "interest", "living_habbits", "short_description"]
      document_values = ["surety_bond", "id_card", "credit_report", "employer", "salary_certificate", "self_disclosure"]
      count +=1 if $scope.userProfileCompletion.avatar.url
      $.each document_values, (index, value) ->
        count +=1 if $scope.documents[value].uploaded
        return
      $.each countable_values, (index, value) ->
        if value == 'interest' or value == 'living_habbits'
          $.each $scope.userProfileCompletion[value], (key, val) ->
            if val == true
              count += 1
              return false
            return
        count += 1  if value isnt 'interest' and value isnt 'living_habbits' and $scope.userProfileCompletion[value] isnt null and $scope.userProfileCompletion[value] isnt ""
        return
      total_percentage = (Math.round((count*100)/23)).toString() + "%"
      $scope.profileComplitionText = total_percentage + " " + $translate.instant('PROFILE_PAGE.PROFILE_COMPLETION.COMPLETE_TXT')
      return total_percentage

    $scope.documents = Premium.propertyDocs(tenant_id: $scope.user.id)

    $scope.tenant_doc =
      upload_popup: false
      report_popup: false
      delete_popup: false
      title_name: ""
      type_name: ""
      type: ""
      doc_id: ""

    $scope.openDocUploadPopup = (type, type_name, title_name) ->
      if $scope.documents[type]
        $scope.tenant_doc.upload_popup = true
        $scope.tenant_doc.type_name = type_name
        $scope.tenant_doc.type = type
        $scope.tenant_doc.title_name = title_name

    $scope.closeDocUploadPopup = () ->
      $scope.tenant_doc.upload_popup = false

    $scope.openUploadReportPopup = () ->
      $scope.upload_errors = []
      $scope.tenant_doc.report_popup = true

    $scope.closeUploadReportPopup = () ->
      $scope.tenant_doc.report_popup = false

    $scope.$on 'property:docs', (ev, response)->
      $scope.documents = response.documents
      $scope.initiallizeDocument()

    $scope.initializeAppointment = () ->
      #$scope.appointmentSection.appointmentSelected = false
      $scope.appointmentSection.suggestionMessage = ""
      $scope.selectedCount = 0

    $scope.onDocSelect = ($files) ->
      if($files[0] != undefined)
        Premium.upload_doc({user_id: currentUser.id, file: $files, type: $scope.tenant_doc.type, locale: "fr"})
        jQuery("#spinner_container").show()
        jQuery("#spinner_background").show()

    $scope.openDocBrowse = () ->
      jQuery("#doc_file").click()
      return true

    $scope.initiallizeDocument = () ->
      $scope.closeDocUploadPopup()
      $scope.closeUploadReportPopup()
      $scope.closeDeleteDocPopup()

    $scope.$on 'upload:doc_response', (ev, response)->
      jQuery("#spinner_container").hide()
      jQuery("#spinner_background").hide()
      if response.success == true
        $scope.initiallizeDocument()
        Premium.propertyDocs(tenant_id: $scope.user.id)
      else
        i = 0
        while i < response.error_messages.length
          e_msg = response.error_messages[i]
          if(e_msg == "Document file size_gt_10_mb")
            response.error_messages[i] = $translate.instant('TENANT_PAGE.UPLOAD_REPORT_POPUP.DOC_SIZE_ERROR')
          else if(e_msg == "Document file type_not_allowed")
            response.error_messages[i] = $translate.instant('TENANT_PAGE.UPLOAD_REPORT_POPUP.DOC_TYPE_ERROR')
          i++
        $scope.upload_errors = response.error_messages


    $scope.deleteDocument = (doc_id) ->
      if doc_id != ""
        Premium.delete_document(doc_id)

    $scope.$on 'delete_doc:response', (ev, response)->
      if response.success == true
        Premium.propertyDocs(tenant_id: $scope.user.id)
      else
        alert("Problem in deleting document, Please try again!")

    $scope.openDeleteDocPopup = (type) ->
      $scope.tenant_doc.doc_id = $scope.documents[type].doc_id
      $scope.tenant_doc.delete_popup = true

    $scope.closeDeleteDocPopup = () ->
      $scope.tenant_doc.doc_id = ""
      $scope.tenant_doc.delete_popup = false

    $scope.onFileSelect = ($files)->
      Authenticate.updateAvatar($files[0])

    $scope.today = ->
     $scope.dt = new Date()
     return

    $scope.change_password = () ->
      $scope.changePassword = true

    $scope.nochange_password = () ->
      $scope.changePassword = false

    $scope.today()
    $scope.showWeeks = false
    $scope.toggleWeeks = ->
      $scope.showWeeks = not $scope.showWeeks
      return

    $scope.clear = ->
      $scope.dt = null
      return

    $rootScope.deleteAccount = () ->
      jQuery("#deleteAccountModal").modal("show")
      jQuery("#deleteAccountModal").parent().show()
      $rootScope.error = false
      false

    $scope.deleteUserConfirm = (reason) ->
      Authenticate.deleteMyAccount(reason)

    $scope.$on 'user:deleted', (ev, response)->
      jQuery("#deleteAccountModal").modal("hide")
      jQuery("#deleteAccountModal").parent().hide()
      jQuery(".modal-backdrop.fade.in").remove()
      window.location.reload()

    $scope.toggleMin = ->
      $scope.minDate = (if ($scope.minDate) then null else new Date())
      return

    $scope.toggleMin()

    $scope.open = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      $scope.opened = true
      return

    $scope.dateOptions =
      "year-format": "'yy'"
      "starting-day": 1

    $scope.formats = [
      "dd-MMMM-yyyy"
      "yyyy/MM/dd"
      "shortDate"
    ]
    $scope.format = $scope.formats[0]

    $scope.updateUser = (user)->
      Authenticate.updateUser(current_user: user, change_password: $scope.changePassword)

    $scope.$on "user:updated:fail", (ev, response)->
      $scope.userErrors.push(response.message)

    $scope.$on "user:updated", (ev, response)->
      $translate.use $.cookie("myLanguage")
      if response.message == "password changed"
        $location.path("/")
        window.location.reload()
      else
        $location.path("/")

    $scope.$on "avatar:updated", (ev, response)->
      if response.success == true
        $scope.user.avatar = response.avatar.avatar
      else
        $scope.alert_errors = response.error_messages
        jQuery("#alertpopupenable").click();
      return

    #=================Profile section Start===========================


    $scope.education_options = ["NO_CONCLUSION", "SECONDARY", "SCHOOL", "COLLEGE", "HIGH_SCHOOL", "STUDY"]

    $scope.relationship_options = ["SINGLE", "RELATIONSHIP", "MARRIED"]

    $scope.interest_options = {sport: "SPORT_TXT",travel: "TRAVEL_TXT",theatre: "THEATRE_TXT",photographie: "FOTOGRAFIE_TXT",movie: "FILM_MOVIE_TXT",literature: "LITERATURE_TXT",art: "ART_TXT",music: "MUSIC_TXT",architecture: "ARCHITECTURE_TXT",cooking: "COOKING_TXT",family: "FAMILY_TXT"}

    $scope.changeUserInterest = () ->
      $scope.user_interests = ""
      count = 1
      for key of $scope.user.interest
        if count <= 4
          if $scope.user.interest[key]
            if count == 4
              $scope.user_interests += "..."
            else
              if $scope.user_interests != ""
                $scope.user_interests += ", "
              $scope.user_interests += $translate.instant("PROFILE_PAGE.LEISURE_INTEREST_SECTION." + $scope.interest_options[key])
            count++

    $scope.changeUserInterest()

    $scope.profileActiveTab = "short_profile"

    $scope.user_gender = ""
    $scope.user_dob = ""

    $scope.changeProfileActiveTab = (tab) ->
      $scope.profileActiveTab = tab

    $scope.changeProfileImg = () ->
      jQuery("#profile_image").click()

    jQuery(document).on "click", ".box-sd a", (e) ->
      jQuery(".box-sd").removeClass "open"
      jQuery(this).parent().toggleClass "open", 1000
      return

    jQuery(document).click (e) ->
      jQuery(".box-sd").removeClass "open"  if jQuery(e.target).parents(".open").length is 0
      return

    $scope.updateProfile = (data) ->
      Authenticate.updateProfile({profile: data, id: $scope.user.id})

    Authenticate.getcurrentUser()

    $scope.$on "setUser:response", (ev, response)->
      $scope.user_gender = response.gender
      $scope.user_dob = response.dob


    $scope.$on "profileupdate:response", (ev, response)->
      $scope.userProfileCompletion = response.user
      $scope.user_gender = response.user.gender
      $scope.user_dob = response.user.dob

    $scope.changeGender = (value) ->
      $scope.user.gender = value
      $scope.updateProfile({gender: $scope.user.gender})

    $scope.changeDOB = (value) ->
      $scope.user.dob = value
      $scope.updateProfile({dob: $scope.user.dob})

    $scope.selectInterest = (type) ->
      $scope.user.interest[type] = !($scope.user.interest[type])
      $scope.updateProfile({interest: $scope.user.interest})
      $scope.changeUserInterest()

    $scope.changeLivingHabbit = (type) ->
      $scope.user.living_habbits[type] = !$scope.user.living_habbits[type]
      $scope.updateProfile({living_habbits: $scope.user.living_habbits})

    $scope.dobInYears = ()->
      today = new Date()
      birthDate = new Date($scope.user_dob)
      age = today.getFullYear() - birthDate.getFullYear()
      m = today.getMonth() - birthDate.getMonth()
      age--  if m < 0 or (m is 0 and today.getDate() < birthDate.getDate())
      age + " " + ((if age <= 1 then $translate.instant('PROFILE_PAGE.YEAR_TXT') else $translate.instant('PROFILE_PAGE.YEARS_TXT')))

    $scope.current_date = new Date()

    #=================Profile section End===========================

]
