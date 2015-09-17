// ==UserScript==
// @name         Instant Topic Unbind for Zhihu
// @namespace    http://huangtao.me/
// @version      0.1
// @description  batch topic unbinding
// @author       tao@zhihu.com
// @match        http://www.zhihu.com/topic/*/questions*
// @grant        none
// ==/UserScript==

var max_pages = 10;

var style_string = '.i4z-btns{position:fixed;}#i4z-topic-unbind-btns{top:200px;left:50px;}.zg-btn{margin-bottom:5px;}';
$('<style/>').html(style_string).appendTo('head');

function i4z_question_topics_pager () {
  var $btn = $('#i4z-topic-questions-load');
  if ($btn.hasClass('disabled')) return;
  $btn.addClass('disabled');

  var cur_page = parseInt($('.zm-invite-pager .zg-gray-normal').last().text());
  var last_page = parseInt($('.zm-invite-pager > span > a').eq(-2).text());
  var num_pages = Math.min(cur_page + max_pages, last_page);
  var $container = $('.zm-topic-list-container');
  for (var i = cur_page + 1; i <= num_pages; i++) {
    $.ajax({
      url: location.pathname,
      method: 'GET',
      data: { page: i },
      success: function(html) {
        $('#zh-topic-questions-list', html).attr('id', null).appendTo($container);
      }
    });
  };
}

function i4z_load_question_topics () {
  $('.zu-top-feed-list .question-item').not('.i4z-loaded').each(function(idx){
    var $el = $(this);
    var href = $('a.question_link', $el).attr('href');
    $.ajax({
      url: href + '/followers',
      success: function(html) {
        var qid = $('#zh-question-side-header-wrap .follow-button', html).data('id');
        var $topics = $('<div />').addClass('zg-clear').addClass('i4z-topics');
        $('.zm-tag-editor-labels .zm-item-tag', html).each(function(){
          var $item = $('<span />').addClass('zm-tag-editor-edit-item').appendTo($topics);
          var tid = $(this).data('topicid');
          $(this).removeClass('zm-item-tag').appendTo($item);
          $('<a />').addClass('zm-tag-editor-remove-button').attr('href','#').data('tid',tid).appendTo($item);
        });
        $topics.insertBefore($el.find('h2'));
        $el.data('qid', qid).addClass('i4z-loaded');
      }
    });
  });
}

function i4z_question_topics_unbind ($el) {
  var qid = $el.closest('.question-item').data('qid');
  var tid = $el.data('tid');
  console.debug('unbind', qid, tid);
  $.ajax({
    url: '/topic/unbind',
    method: 'POST',
    data: {
      qid: qid,
      question_id: qid,
      topic_id: tid
    },
    success: function(data) {
      if (data.r != 0) return;
      $el.closest('.zm-tag-editor-edit-item').remove();
    }
  });
}

$('.zm-topic-list-container').on('click', '.zm-tag-editor-remove-button', function(e) {
  i4z_question_topics_unbind($(e.target));
});

var $btns = $('<div />')
  .attr('id', 'i4z-topic-unbind-btns')
  .addClass('i4z-btns');

$('<div />')
  .attr('id', 'i4z-topic-questions-load')
  .addClass('zg-btn').addClass('zg-btn-white')
  .text('自动加载' + max_pages + '页')
  .click(i4z_question_topics_pager)
  .appendTo($btns);

$('<div />')
  .attr('id', 'i4z-load-question-topics')
  .addClass('zg-btn').addClass('zg-btn-white')
  .text('加载话题')
  .click(i4z_load_question_topics)
  .appendTo($btns);

$btns.appendTo('body');
