service = angular.module('Authenticate', ['ngResource'])

service.factory('Authenticate', ['$rootScope', '$http', '$upload', '$q', "$route", "$routeParams",
   ($rootScope, $http, $upload, $q, $route, $routeParams)->
      isLoggedIn: (currentUser != undefined) && (currentUser != null)
      isRegistered: (currentUser != undefined) && (currentUser != null) && (currentUser.registered_user == true)

      signUp: (params)->
        if params.avatar
          $upload.upload({
            url: '/sign_up.json',
            method: 'POST',
            data: {authentication: params}
            file: params.avatar,
          }).success (data)->
            if data.success
              $rootScope.$broadcast "user:signedIn", data
            else
              $rootScope.$broadcast "user:signedUp:fail", data
        else
          $http.post('/sign_up.json', params).success (data)->
            if data.success
              $rootScope.$broadcast "user:signedIn", data
            else
              $rootScope.$broadcast "user:signedUp:fail", data

      signIn: (params)->
        $http.post('/sign_in.json', params).success (data)->
          $rootScope.$broadcast "user:signedIn", data

      update: (params)->
        $http.post('/update_user.json', params).success (data)->
          if data.success
            $rootScope.$broadcast "user:signedIn", data
          else
            $rootScope.$broadcast "user:signedUp:fail", data

      updateUser: (params) ->
        $http.post('/api/users.json', params).success (data)->
          if data.success
            $rootScope.$broadcast "user:updated", data
          else
            $rootScope.$broadcast "user:updated:fail", data

      deleteMyAccount: (params) ->
        $http.post('/api/users/deactive_account.json', params).success (data)->
          if data.success
            $rootScope.$broadcast "user:deleted", data

      updateAvatar: (params) ->
        $upload.upload({
          url: '/api/users/update_avatar.json',
          method: 'POST',
          file: params,
        }).success (data)->
          $rootScope.$broadcast "avatar:updated", data
             
        
      signOut: (params)->
        $http.delete('/sign_out.json', params).success (data)->
          $rootScope.$broadcast "user:signOut", data

      emailCheck: (params) ->
        $http.post('/email_check.json', params).success (data)->
          $rootScope.$broadcast "email:validity", data

      currentUser: ()->
        deferred = $q.defer()
        xhr = $http.get('/current_user')
        xhr.success((data)->
          deferred.resolve(data)
        )
        xhr.error((data)->
          deferred.resolve("error value");
        )
        return deferred.promise

      getcurrentUser: () ->
        $http.get('/current_user').success (data)->
          $rootScope.$broadcast "setUser:response", data

      updateProfile: (params) ->
        $http.post('/api/users/' + params.id + '/update_profile.json', params).success (data)->
          $rootScope.$broadcast "profileupdate:response", data
])
