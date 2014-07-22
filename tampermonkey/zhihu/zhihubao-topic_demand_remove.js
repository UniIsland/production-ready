// ==UserScript==
// @name       zhihubao - 批准话题删除申请
// @namespace  http://bao.zhihu.com/
// @version    0.1
// @description  enter something useful
// @match      http://bao.zhihu.com/admin/topic/demand/remove*
// @copyright  2012+, You
// ==/UserScript==

// javascript:(function(){$('input.deleteTopic').each(function(){var $T=$(this);$.post('/admin/topic',{topic_id:$T.attr('topicid'),_method:'delete'},function(){$T.remove()})});})();

var request_post_url = '/admin/topic/demand/remove';
var request_data_operation = 'pass';
var $table = $('#search-results');

var max_pages = 170;
var min_keep = 1;
var min_questions = 1;
var min_followers = 10;
var min_children = 1;

var style_string = '#zhb-topic-remove-btns {position:absolute;top:120px;right:100px;}';
style_string += '#zhb-topic-remove-btns .btn {float:right;}';
//style_string += '#zhb-topic-remove-all-btn {padding:4px 16px;background-color:#da4f49;border:1px solid #999}'
$('<style/>').html(style_string).appendTo('head');
var active_ajax = {};


function zhb_topic_remove_selected() {
  var n = 0;
  $('input.zhb-check:checked').each(function (){
    var $this = $(this);
    var $tr = $this.closest('tr');
    var t_id = $tr.attr('t_id');
    var d_id = $tr.attr('d_id');
    $.ajax({
      type: 'POST',
      url: request_post_url,
      data: {
        operation: 'pass',
        topic_id: t_id,
        demand_id: d_id
      },
      dataType: 'json',
      success: function(data) {
        $this.remove();
        $tr.css('color','green');
        $('a',$tr).css('color','green');
      }
    });
    n++;
  });
  active_ajax.msg = 'finished ignoring: ' + n;
}
function zhb_topic_ignore_selected() {
  var n = 0;
  $('input.zhb-check:checked').each(function (){
    var $this = $(this);
    var $tr = $this.closest('tr');
    var t_id = $tr.attr('t_id');
    var d_id = $tr.attr('d_id');
    var num_q = $tr.attr('num_q');
    var num_f = $tr.attr('num_f');
    var num_c = $tr.attr('num_c');
    var regex = new RegExp("/topic/([0-9]*)$");
    var $link = $('td:eq(1) a',$tr);
    var token = regex.exec($link.attr('href'))[1];
    var name = $link.text();
    console.log(token+','+num_q+','+num_f+','+num_c+',"'+name+'"');
    $.ajax({
      type: 'POST',
      url: request_post_url,
      data: {
        operation: 'ignore',
        topic_id: t_id,
        demand_id: d_id
      },
      dataType: 'json',
      success: function(data) {
        $this.remove();
        $tr.css('color','orange');
        $('a',$tr).css('color','orange');
      }
    });
    n++;
  });
  active_ajax.msg = 'finished ignoring: ' + n;
}
function zhb_topic_ignore_all() {
  var n = 0;
  var remain = 0;
  var $btn = $('#zhb-topic-ignore-all-btn');
  var $remain = $('<span />').text(' ('+remain+')').appendTo($btn);
  $('input.zhb-check').each(function (){
    var $this = $(this);
    var $tr = $this.closest('tr');
    var t_id = $tr.attr('t_id');
    var d_id = $tr.attr('d_id');
    var num_q = $tr.attr('num_q');
    var num_f = $tr.attr('num_f');
    var num_c = $tr.attr('num_c');
    var locked = this.checked;
    //console.debug(d_id,t_id,num_q,num_f,locked);
    if (Math.max(num_q,num_f,num_c) < min_keep && ! locked) {
      return;
    }
    var regex = new RegExp("/topic/([0-9]*)$");
    var $link = $('td:eq(1) a',$tr);
    var token = regex.exec($link.attr('href'))[1];
    var name = $link.text();
    //console.log(token+','+num_q+','+num_f+','+num_c+',"'+name+'"');
    $.ajax({
      type: 'POST',
      url: request_post_url,
      data: {
        operation: 'ignore',
        topic_id: t_id,
        demand_id: d_id
      },
      dataType: 'json',
      success: function(data) {
        $this.remove();
        $tr.css('color','orange');
        $('a',$tr).css('color','orange');
        $remain.text(' ('+(--remain)+')');
      }
    });
    n++;
  });
  remain += n;
  active_ajax.msg = 'finished ignoring: ' + n;
  active_ajax.$counter = $remain;
}
function zhb_topic_remove_all() {
  var n = 0;
  var remain = 0;
  var $btn = $('#zhb-topic-remove-all-btn');
  var $remain = $('<span />').text(' ('+remain+')').appendTo($btn);
  $('input.zhb-check').each(function (){
    var $this = $(this);
    var $tr = $this.closest('tr');
    var t_id = $tr.attr('t_id');
    var d_id = $tr.attr('d_id');
    var num_q = $tr.attr('num_q');
    var num_f = $tr.attr('num_f');
    var num_c = $tr.attr('num_c');
    var locked = this.checked;
    //console.debug(d_id,t_id,num_q,num_f,locked);
    if (num_q >= min_questions || num_f >= min_followers || num_c >= min_children || locked) {
      $tr.css('color','red');
      $('a',$tr).css('color','red');
      return;
    }
    $.ajax({
      type: 'POST',
      url: request_post_url,
      data: {
        operation: 'pass',
        topic_id: t_id,
        demand_id: d_id
      },
      dataType: 'json',
      success: function(data) {
        $this.remove();
        $tr.css('color','green');
        $('a',$tr).css('color','green');
        $remain.text(' ('+(--remain)+')');
      }
    });
    n++;
  });
  remain += n;
  active_ajax.msg = 'finished deleting: ' + n;
  active_ajax.$counter = $remain;
}
function zhb_topic_batch_proc() {
  var n = 0;
  var m = 0;
  var remain = 0;
  var $btn = $('#zhb-topic-batch-btn');
  var $remain = $('<span />').text(' ('+remain+')').appendTo($btn);
  $('input.zhb-check').each(function (){
    var $this = $(this);
    var $tr = $this.closest('tr');
    var t_id = $tr.attr('t_id');
    var d_id = $tr.attr('d_id');
    var num_q = $tr.attr('num_q');
    var num_f = $tr.attr('num_f');
    var num_c = $tr.attr('num_c');
    var locked = this.checked;
    //console.debug(d_id,t_id,num_q,num_f,locked);
    if (num_q > 3 || num_c > 0 || locked) return;
    var op = 'ignore';
    var color = 'green';
    m++;
    if ((num_q == 0 && num_f < 10) || (num_q == 1 && num_f < 4) || (num_q == 2 && num_f < 2) || (num_q == 3 && num_f == 0)) {
      op = 'pass';
      color = 'red';
      n++;
      m--;
    }
    $tr.css('color',color);
    $('a',$tr).css('color',color);
    $.ajax({
      type: 'POST',
      url: request_post_url,
      data: {
        operation: op,
        topic_id: t_id,
        demand_id: d_id
      },
      dataType: 'json',
      success: function(data) {
        $this.remove();
        $remain.text(' ('+(--remain)+')');
      }
    });
  });
  remain += n+m;
  active_ajax.msg = 'finished deleting: ' + n + ', finished ignoring: ' + m;
  active_ajax.$counter = $remain;
}
function zhb_topic_sort_func(el) {
    var $el = $(el);
    var score = parseInt($el.attr('num_q'))*100 + parseInt($el.attr('num_f')) + parseInt($el.attr('num_c'))*10000;
    if ($('.zhb-check',$el).length == 0) score = score * (-1) - 1;
    return score;
}
function zhb_topic_sort_again () {
    var $tr = $('tr').detach();
    $tr.sort(function (a, b){
      return zhb_topic_sort_func(b) - zhb_topic_sort_func(a);
    });
    $tr.appendTo($('table tbody').first());
}
function zhb_topic_sort () {
    $('ul.pagination').remove();
    var $thead = $('thead > tr').first().detach();
    $('thead').remove();
    var $tr = $('tr').detach();
    console.log('tr.size:',$tr.length);
    $tr.each(function() {
      var $el = $(this);
      var $pass = $('.remove-pass', $el);
      var $col = $('td', $el);
      $el
        .attr('t_id', $pass.attr('_topic_id'))
        .attr('d_id', $pass.attr('_demand_id'))
        .attr('num_q', parseInt($('a', $col[2]).text()))
        .attr('num_f', parseInt($($col[3]).text()))
        .attr('num_c', parseInt($($col[4]).text()));
      $('<input type="checkbox" />')
        .addClass('zhb-check')
        .appendTo($('td',$el).last());
      $pass.remove();
      $('.remove-ignore', $el).remove();
    });
    $tr.sort(function (a, b){
      return zhb_topic_sort_func(b) - zhb_topic_sort_func(a);
    });
    //$tr.sort(function(a,b){
    //  var na = $('td:eq(1) a',a).text(), nb = $('td:eq(1) a',b).text();
    //    return (na.length < nb.length ? 1 : (na.length > nb.length ? -1 : (na < nb ? -1 : (na > nb ? 1 : 0))));
    //});
    $thead.appendTo($('table tbody').first());
    $tr.appendTo($('table tbody').first());
}
function zhb_topic_remove_load () {
  var $btn = $('#zhb-topic-remove-load-btn');
  if ($btn.hasClass('disabled')) return;
  var $container = $table.parent();
  var cur_page = parseInt($('.pagination li.active a').text());
  var regex = new RegExp("（([0-9]*)）");
  var num_pages = parseInt(regex.exec($('.pagination li:last a').text())[1]);
  var num_pages = Math.min(cur_page + max_pages, num_pages);
  var remain = num_pages - cur_page;
  var $remain = $('<span />').text(' ('+remain+')').appendTo($btn);
  $btn.addClass('disabled');
  active_ajax.$counter = $remain;
  active_ajax.callback = zhb_topic_sort;
  active_ajax.msg = 'finished loading ' + remain + ' pages.'
  for (var i = cur_page + 1; i <= num_pages; i++) {
    $.ajax({
      url: location.pathname,
      type: 'GET',
      data: { page: i },
      success: function(data) {
        $('#search-results',data).attr('id','').appendTo($container);
        $remain.text(' ('+(--remain)+')');
      }
    });
  }
}

$(document).ajaxStop(function() {
  active_ajax.msg && console.log(active_ajax.msg);
  active_ajax.$counter && active_ajax.$counter.remove();
  active_ajax.callback && active_ajax.callback();
  active_ajax = {
    $counter: undefined,
    msg: undefined,
    callback: undefined
  };
});


var $btns = $('<div />')
  .attr('id','zhb-topic-remove-btns')
  .appendTo('body');

$('<div />')
  .attr('id','zhb-topic-remove-all-btn')
  .addClass('zhb-btn').addClass('btn').addClass('btn-danger')
  .text('条件删除 ' + min_questions +'/'+ min_followers +'/'+ min_children)
  .click(zhb_topic_remove_all)
  .appendTo($btns);

$('<div />')
  .attr('id','zhb-topic-remove-btn')
  .addClass('zhb-btn').addClass('btn').addClass('btn-danger')
  .text('删除选中')
  .click(zhb_topic_remove_selected)
  .appendTo($btns);

$('<div />')
  .attr('id','zhb-topic-batch-btn')
  .addClass('zhb-btn').addClass('btn').addClass('btn-danger')
  .text('批处理 0/9,1/3,2/1,3/0')
  //.click(zhb_topic_batch_proc)
  .appendTo($btns);


$('<div />')
  .attr('id','zhb-topic-ignore-all-btn')
  .addClass('zhb-btn').addClass('btn').addClass('btn-default')
  .text('条件忽略 ' + min_keep)
  //.click(zhb_topic_ignore_all)
  .appendTo($btns);

$('<div />')
  .attr('id','zhb-topic-ignore-btn')
  .addClass('zhb-btn').addClass('btn').addClass('btn-default')
  .text('忽略选中')
  .click(zhb_topic_ignore_selected)
  .appendTo($btns);

$('<div />')
  .attr('id','zhb-topic-sort-btn')
  .addClass('zhb-btn').addClass('btn').addClass('btn-default')
  .text('排序')
  .click(zhb_topic_sort_again)
  .appendTo($btns);

$('<div />')
  .attr('id','zhb-topic-remove-load-btn')
  .addClass('zhb-btn').addClass('btn').addClass('btn-default')
  .text('加载' + max_pages + '页')
  .click(zhb_topic_remove_load)
  .appendTo($btns);
