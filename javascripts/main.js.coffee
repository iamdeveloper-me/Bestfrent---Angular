getLanguageFromCookie = ->
  if(!$.cookie("myLanguage"))
     $.cookie("myLanguage", 'en')
  return $.cookie("myLanguage")

@bestfrent = angular.module("bestfrent",[
  'ngRoute',
  'templates',
  'ngAutocomplete',
  'igTruncate',
  'facebook',
  'ui.bootstrap',
  'ngMap',
  'infinite-scroll',
  'ui.slider',
  'mgcrea.ngStrap',
  'angularFileUpload',
  'angular-flexslider',
  'Property',
  'Premium',
  'Authenticate',
  'Notification',
  'landingController',
  'offerController',
  'signupController',
  'propertyController',
  'ShowPropertyController',
  'EditPropertyController',
  'UserController',
  'PremiumController',
  'LandLordController',
  'pascalprecht.translate',
  'ngCookies'
])

@bestfrent.run(["$location", "$route", "$rootScope", "Authenticate", "Notification", ($location, $route, $rootScope, Authenticate, Notification)->
  if currentUser
    $rootScope.currentUser = currentUser
    Notification.myNotification()
  else
    $rootScope.my_notification = {}
  $rootScope.$on('$locationChangeStart', (ev, next, current)->

    nextPath = $location.path()
    nextRoute = $route.routes[nextPath]
    if (nextRoute && (nextPath == "/sign_up" || nextPath == "/register_confirm") && Authenticate.isLoggedIn && Authenticate.isRegistered)
      $location.path("/")
    if (nextRoute && nextRoute.auth && !Authenticate.isLoggedIn)
      $location.path("/");
  )
])

@bestfrent.filter "titleCase", ->
  (input) ->
    words = input.split(" ")
    i = 0
    while i < words.length
      words[i] = words[i].charAt(0).toUpperCase() + words[i].slice(1)
      i++
    words.join " "

@bestfrent.directive "ngEnter", ->
  (scope, element, attrs) ->
    element.bind "keydown keypress", (event) ->
      if event.which is 13
        scope.$apply ->
          scope.$eval attrs.ngEnter
          return
        event.preventDefault()
      return
    return

# Below directive is for accepting only numeric value. just add attribute numeric in input text field to use
@bestfrent.directive 'numeric', ->
  require: "ngModel"
  link: (scope, element, attr, ngModelCtrl) ->
    fromUser = (text) ->
      text = text || ""
      transformedInput = text.replace(/[^0-9]/g, "")
      console.log transformedInput
      if transformedInput isnt text
        ngModelCtrl.$setViewValue transformedInput
        ngModelCtrl.$render()
      transformedInput # or return Number(transformedInput)
    ngModelCtrl.$parsers.push fromUser
    return


@bestfrent.directive 'trimMeOnblur', ->
  require: "ngModel"
  link: (scope, element, attr, ngModelCtrl) ->
    trimFromUser = () ->
      view_value = ngModelCtrl.$viewValue.trim()
      ngModelCtrl.$setViewValue view_value
      ngModelCtrl.$render()
    element.on "blur", ->
      trimFromUser()
    return


@bestfrent.config ($translateProvider) ->
  $translateProvider.useStaticFilesLoader(
    prefix: "languages/"
    suffix: ".json"
  ).preferredLanguage(getLanguageFromCookie())
  return

@bestfrent.config(['FacebookProvider', (FacebookProvider)->
  # FacebookProvider.init('1391574141086520');
  FacebookProvider.init('608218182558744');
])

# @bestfrent.config(["PusherServiceProvider", (PusherServiceProvider) ->
#   PusherServiceProvider.setToken("8bbc01c58c3c6684f64b")
#   PusherServiceProvider.setOptions {}
# ])

@bestfrent.config(["$routeProvider", "$locationProvider", ($routeProvider, $locationProvider)->
  $locationProvider.html5Mode(true)

  $routeProvider
    .when("/",{
      templateUrl: "landing/index.html"
      controller: "LandingController"
    })

    .when("/properties/new",{
      templateUrl: "property/index.html"
      controller: "PropertyController"
      auth: true
      resolve: {
        currentUser: ["Authenticate", (Authenticate)->
          return Authenticate.currentUser()
        ]
      }
    })

    .when("/properties/:id",{
      templateUrl: "offer/show.html"
      controller: "ShowPropertyController"
      resolve: {
        currentProperty: ["Property", "$route", (Property, $route)->
          return Property.getByID($route.current.params.id)
        ]
        currentUser: ["Authenticate", (Authenticate)->
          return Authenticate.currentUser()
        ]
      }
    })

    .when("/properties/:id/edit",{
      templateUrl: "property/index.html"
      controller: "EditPropertyController"
      auth: true
      resolve: {
        property: ["Property", "$route", (Property, $route)->
          return Property.getByID($route.current.params.id)
        ]
      }
    })

    .when("/bestfrent_premium/tenant",{
      templateUrl: "tenant/tenant.html"
      controller: "PremiumController"
      auth: true
      resolve: {
        properties: ["Premium", (Premium)->
          return Premium.interestProperty()
        ]
      }
    })

    .when("/bestfrent_premium/landlord",{
      templateUrl: "landlord/landlord.html"
      controller: "LandLordController"
      auth: true
      resolve: {
        tenantInquiry: ["Premium", (Premium)->
          return Premium.interestedTenants()
        ]
      }
    })

    .when("/users",{
      templateUrl: "user/index.html"
      controller: "UserController"
      auth:true
    })

    .when("/my_profile",{
      templateUrl: "user/profile.html"
      controller: "UserController"
      auth:true
    })

    .when("/sign_up",{
      templateUrl: "signup/index.html"
      controller: "SignupController"
    })

    .when("/register_confirm",{
      templateUrl: "signup/index.html"
      auth:true
      controller: "SignupController"
    })

    .when("/bestfrent_premium",{
      templateUrl: "premium/index.html"
      controller: "PremiumController"
      auth:true
      resolve: {
        properties: ()->
          return null
      }
    })

    .when("/properties",{
      templateUrl: "offer/index.html"
      controller: "offerController"
      auth: true
      resolve: {
        properties: ["Property", "$route", (Property, $route)->
          return Property.userProperties()
        ]
        currentUser: ["Authenticate", (Authenticate)->
          return Authenticate.currentUser()
        ]
      }
    })

    .when("/dashboard/landlord",{
      templateUrl: "dashboard/landlord.html"
      controller: "LandlordDashboardController"
      auth: true
      resolve: {
        properties: ()->
          return null
      }
    })

    .when("/dashboard/tenant",{
      templateUrl: "dashboard/tenant.html"
      controller: "TenantDashboardController"
      auth: true
      resolve: {
        properties: ()->
          return null
      }
    })

   .otherwise({
      templateUrl: "landing/index.html"
    })
])

# Below filter is to show the notification count in whole application. Need to optimize below filter.
@bestfrent.filter "display_notification", ->
  (notifi,user,type,properties,tenants,show_zero,tabs) ->
    count = 0
    tenants = tenants || []
    show_zero = show_zero || false
    if notifi
      if(user.indexOf('tenant') != -1)
        if (notifi["tenant"] != undefined)
          $.each properties, (index,property) ->
            if (notifi.tenant["property_" + property.id] != undefined)
              if(['message','property'].indexOf(type) != -1)
                count = count + (notifi.tenant["property_" + property.id].message || 0)
              if(['appointment','property'].indexOf(type) != -1)
                count = count + (notifi.tenant["property_" + property.id].appointment || 0)
              if(['document','property'].indexOf(type) != -1)
                count = count + (notifi.tenant["property_" + property.id].document || 0)
              if(['contract','property'].indexOf(type) != -1)
                count = count + (notifi.tenant["property_" + property.id].contract || 0)
              if(['payment','property'].indexOf(type) != -1)
                count = count + (notifi.tenant["property_" + property.id].payment || 0)

          if(type == "properties")
            $.each notifi["tenant"], (p_index,p) ->
              $.each p, (k,v) ->
                count = count + v
          else if(type == "dashboard")
            $.each notifi["tenant"], (p_index,p) ->
              $.each p, (k,v) ->
                count = count + v if (tabs.indexOf(k) != -1)


      if (user.indexOf('landlord') != -1)
        if (notifi["landlord"] != undefined)
          $.each properties, (index,property) ->
            if (notifi.landlord["property_" + property.id] != undefined)
              $.each tenants, (index,tenant) ->
                if (notifi.landlord["property_" + property.id]["tenant_" + tenant.id] != undefined)
                  count = count + (notifi.landlord["property_" + property.id]["tenant_" + tenant.id].message || 0) if (['message','property'].indexOf(type) != -1)
                  count = count + (notifi.landlord["property_" + property.id]["tenant_" + tenant.id].appointment || 0) if (['appointment','property'].indexOf(type) != -1)
                  count = count + (notifi.landlord["property_" + property.id]["tenant_" + tenant.id].document || 0) if (['document','property'].indexOf(type) != -1)
                  count = count + (notifi.landlord["property_" + property.id]["tenant_" + tenant.id].contract || 0) if (['contract','property'].indexOf(type) != -1)
                  count = count + (notifi.landlord["property_" + property.id]["tenant_" + tenant.id].payment || 0) if (['payment','property'].indexOf(type) != -1)

              if (type == 'property_tenants')
                $.each notifi.landlord["property_" + property.id], (key,value) ->
                  $.each value, (k,v) ->
                    count = count + v
          if(type == "properties")
            $.each notifi["landlord"], (p_index,p) ->
              $.each p, (t_index,t) ->
                $.each t, (k,v) ->
                  count = count + v
          else if(type == "dashboard")
            $.each notifi["landlord"], (p_index,p) ->
              $.each p, (t_index,t) ->
                $.each t, (k,v) ->
                  count = count + v if (tabs.indexOf(k) != -1)

    if !show_zero
      count = "" if count == 0
    return count

@bestfrent.directive "scrollable", [->
  link: (scope, elem) ->
    elem.mCustomScrollbar
      #autoHideScrollbar: false
      #theme: "dark"
      advanced:
        updateOnContentResize: true
    return
]
