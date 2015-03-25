//= require "angular/angular.min.js"
//= require "angular-route/angular-route.min.js"
//= require "angular-animate/angular-animate.min.js"
//= require_tree .

angular.module('homepageApp', [
  'ngRoute',
  'ngAnimate'
])
.config(['$routeProvider', function($routeProvider) {

  $routeProvider
    .when('/about', {
      templateUrl: '/pages/about.html'
    })
   .when('/work/:name', {
      templateUrl: function(attrs) {
        return '/pages/work/' + attrs.name + '.html';
      }
    })
   .when('/work', {
      templateUrl: '/pages/work.html'
    })
   .when('/resume', {
      templateUrl: '/pages/resume.html'
    })
   .when('/', {
      templateUrl: '/pages/home.html'
    });
}]);
