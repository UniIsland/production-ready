// ==UserScript==
// @name       last.fm - scrobble any track
// @namespace  http://last.fm/
// @version    0.1
// @description  enter something useful
// @match      http://www.last.fm/music/*
// @copyright  2014+, You
// ==/UserScript==

(function($) {

var track_list_selectors = [
  '#artist-top-tracks', // artist page
  '#albumTracklist', // album page
  'table.candyStriped.chart' // tracks page
];

var style_string = '#tm-main-control {position:absolute;top:20px;right:20px;}';
style_string += '#tm-scrobble-all {position:absolute;top:80px;right:20px;}';
style_string += '.tm-btn {display:inline-block;float:right;width:25px;height:20px;background-image:url("http://cdn.lst.fm/flatness/sprites/21/icons.png");background-position:-5px -1458px;background-repeat:no-repeat;cursor:pointer;text-align:right;}';
//style_string += '#zhb-topic-remove-all-btn {padding:4px 16px;background-color:#da4f49;border:1px solid #999}'
$('<style/>').html(style_string).appendTo('head');

var formtoken = $('input[name="formtoken"]').val();

function scrobble_track() {
  var $t = $(this);
  var ajax_param = {
    url: '/ajax/scrobble',
    type: 'POST',
    data: {
      track: $t.data('tid'),
      application: 'flp',
      formtoken: formtoken
    },
    success: function (data) {
      if (data.response == 'OK') {
        var n = parseInt($t.text()) || 0;
        $t.text(n + 1);
      } else {
        console.error('scrobbling failed', data, $t);
      }
    }
  }
  $.ajax(ajax_param);
}
function scrobble_all_track() {
  $('.tm-btn').click();
}
function clear_scrobble_btns () {
  $('.tm-btn').remove();
}
function show_scrobble_btns () {
  clear_scrobble_btns();
  $('table.candyStriped.chart tbody tr')
    .each(function(){
      var $tr = $(this);
      var $cell = $('.subjectCell > div', $tr);
      if ($cell.length == 0)
        $cell = $('.subjectCell', $tr);
      $('<span />')
        .addClass('tm-btn')
        .data('tid',$tr.data('track-id'))
        .click(scrobble_track)
        .appendTo($cell);
    });
}

var $btn_main = $('<div />')
  .attr('id','tm-main-control')
  .addClass('btn')
  .text('Scrobbler On')
  .click(show_scrobble_btns)
  .appendTo('body');
var $btn_scrobble_all = $('<div />')
  .attr('id','tm-scrobble-all')
  .addClass('btn')
  .text('Scrobble All')
  .click(scrobble_all_track)
  .appendTo('body');

show_scrobble_btns();

})(jQuery);
