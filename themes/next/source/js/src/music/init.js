// // 移动设备侦测
// var isMobile = {
//   Android: function() {
//     return navigator.userAgent.match(/Android/i);
//   },
//   BlackBerry: function() {
//     return navigator.userAgent.match(/BlackBerry/i);
//   },
//   iOS: function() {
//     return navigator.userAgent.match(/iPhone|iPad|iPod/i);
//   },
//   Opera: function() {
//     return navigator.userAgent.match(/Opera Mini/i);
//   },
//   Windows: function() {
//     return navigator.userAgent.match(/IEMobile/i);
//   },
//   any: function() {
//     return (isMobile.Android() || isMobile.BlackBerry() || isMobile.iOS() || isMobile.Opera() || isMobile.Windows());
//   }
// };

// $(window).on("load", function() {

//   if (!$('#nmlist').size()) {
//     // run music app
//     !isMobile.any() && $.getScript('/js/src/music/nmlist.js');

//     if (window.location.search.indexOf('music') > -1 && isMobile.any()) {
//       $(document).on('touchstart', '.aplayer .aplayer-pic', function(e) {
//         evt.preventDefault();
//         NM.togglePlay();
//       });
//       $.getScript('/js/src/music/nmlist.js');
//     }
//   }
// })