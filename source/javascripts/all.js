//= require "angular-route/angular-route.min.js"
//= require "angular-animate/angular-animate.min.js"
//= require_tree .

var myApp = angular.module('homepageApp', [
  'ngRoute',
  'ngAnimate'
]);

myApp.config(['$routeProvider', function($routeProvider) {

  $routeProvider
    .when('/about', {
      templateUrl: '/pages/about/'
    })
   .when('/work', {
      templateUrl: '/pages/work/'
    })
   .when('/resume', {
      templateUrl: '/pages/resume/'
    })
   .when('/blog', {
      templateUrl: '/pages/blog/'
   })
   .when('/blog/page/:page_num', {
      templateUrl: function(routeParams) {
        return '/pages/blog/page/' + routeParams.page_num + '/';
      }
   })
   .when('/blog/:route*', {
      templateUrl: function(routeParams) {
        return '/blog/' + routeParams.route;
      }
    })
   .when('/', {
      templateUrl: '/pages/home/'
    });
}]);

myApp.run(['$rootScope', '$location', '$timeout', function($rootScope, $location, $timeout) {

    $rootScope.doneLoading = true;

    //used to animate elements via ng-if once the page has changed
    $rootScope.isCurrentPage = {};
    var firstLoad = true;
    $rootScope.$on("$locationChangeSuccess", function() {
        $rootScope.isCurrentPage = {};
        if (firstLoad) {
            animateDelay = 0;
            firstLoad = false;
        } else {
            //trigger element animation after page animation is half over
            pageTransitionDuration = 600;
            animateDelay = pageTransitionDuration / 2;
        }
        $timeout(function() {
            $rootScope.isCurrentPage[$location.path()] = true;
        }, animateDelay);
    });
}]);
