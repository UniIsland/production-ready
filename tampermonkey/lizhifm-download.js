// ==UserScript==
// @name       Download lizhi.fm
// @namespace  http://www.lizhi.fm/
// @version    0.1
// @description  add download link to each episode
// @match      http://www.lizhi.fm/#/*
// @copyright  2012+, You
// ==/UserScript==

function showBtns(){
  $('<style type="text/css"></style>')
    .html('.audioList li a.tm-download{position:absolute;right:80px;top:20px;width:30px;height:30px;display:block;background:url(/images/leftIcon.png) no-repeat;background-position:-30px -490px;padding:0;}')
    .appendTo('head');

  var $audio = $(".audioList a");
  $audio.each(function(){
    var $el = $(this);
    var url = $(this).data('url');
    var filename = $('p', $el).first().text() + '.mp3';
    $('<a>').attr('href',url).attr('download',filename)
      .addClass('tm-download').insertAfter($el);
  });
}

window.setTimeout(function(){
  console.log('run func');
  $('.leftNav .logo a').attr('href','#').click(function(){showBtns();});
},3000);

