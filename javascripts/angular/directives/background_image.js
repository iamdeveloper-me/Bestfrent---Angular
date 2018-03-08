'use strict';

angular.module('bestfrent')
    .directive('ngBackgroundImage', function () {
        return function (scope, element, attrs) {
            if(attrs.ngBackgroundImage) {
                element.css({
                    'background-image': 'url(' + attrs.ngBackgroundImage + ')'
                });
            }

        };
    });
