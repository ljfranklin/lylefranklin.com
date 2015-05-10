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

myApp.controller('LoadingCtrl', ['$scope', '$document', function($scope, $document) {

  var finish = function() {
    $scope.$parent.doneLoading = true;
  };
  $document.ready(function() {
    $scope.$apply(finish);
  });
}]);

myApp.controller('NavCtrl', ['$scope', '$location', function($scope, $location) {
  $scope.isActivePage = function(pageName) {
    return $location.path() === '/' + pageName;
  };
}]);
