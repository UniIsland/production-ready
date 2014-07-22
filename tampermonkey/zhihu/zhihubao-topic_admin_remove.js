// ==UserScript==
// @name       zhihubao - 管理话题（删除）
// @namespace  http://bao.zhihu.com/
// @version    0.1
// @description  enter something useful
// @match      http://bao.zhihu.com/admin/topic?q=*
// @copyright  2012+, You
// ==/UserScript==

// javascript:(function(){$('input.deleteTopic').each(function(){var $T=$(this);$.post('/admin/topic',{topic_id:$T.attr('topicid'),_method:'delete'},function(){$T.remove()})});})();

var request_post_url = '/admin/topic';
var request_data_operation = 'pass';
var $table = $('#search-results');

var min_questions = 4;
var min_followers = 1;
var max_pages = 100;

var style_string = '#zhb-topic-remove-btns {position:absolute;top:120px;right:100px;}';
style_string += '#zhb-topic-remove-btns .btn {float:right;}';
//style_string += '#zhb-topic-remove-all-btn {padding:4px 16px;background-color:#da4f49;border:1px solid #999}'
$('<style/>').html(style_string).appendTo('head');

function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

function zhb_topic_sort_func(el) {
    var $col = $('td', el);
    var num_q = parseInt($('a', $col[3]).text());
    var num_f = parseInt($($col[4]).text());
    var num_w = $('span.label-warning', el).length * 5;
    return num_q + num_f + num_w;
}

function zhb_topic_remove_selected() {
    var $t = $('input.select-check[name="topic_id"]:checked');
    console.log('remove selected: ',$t.length);
    $t.each(function (){
    var $this = $(this);
        var $tr = $this.closest('tr');
        var t_id = $this.val();
        $.ajax({
      type: 'POST',
      url: request_post_url,
      data: {
        _method: 'delete',
        topic_id: t_id
      },
      dataType: 'json',
      success: function(data) {
        $('input.deleteTopic',$tr).remove();
                $tr.css('color','green');
            $('a',$tr).css('color','green');
      }
    });
    });
}

function zhb_topic_remove_all() {
    var n = 0;
  $('input.deleteTopic').each(function (){
    var $this = $(this);
        var $tr = $this.closest('tr');
    var $td = $('td', $tr);
    var t_id = $this.attr('topicid');
    var num_q = parseInt($('a',$td[3]).text());
    var num_f = parseInt($($td[4]).text());
        var locked = $('input:checked', $tr);
        //console.log($this.attr('topicname'),num_q,num_f,locked.length)
    if (num_q >= min_questions || num_f >= min_followers || locked.length > 0) {
      $tr.css('color','red');
            $('a',$tr).css('color','red');
      return;
    }
    $.ajax({
      type: 'POST',
      url: request_post_url,
      data: {
        _method: 'delete',
        topic_id: t_id
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
    console.log('remove all: ', n);
}
function zhb_topic_remove_load () {
    var s = getParameterByName('q');
    var cur_page = parseInt($('.pagination li.active a').text());
    var regex = new RegExp("（([0-9]*)）");
  var num_pages = parseInt(regex.exec($('.pagination li:last a').text())[1]);
    console.log(s,cur_page,cur_page + max_pages,num_pages);
  for (var i = cur_page + 1; i <= cur_page + max_pages && i <= num_pages; i++) {
    $.ajax({
      url: '/admin/topic',
      type: 'GET',
      data: {
                q: s,
                page: i
            },
      success: function(data) {
        $('#search-results',data).attr('id','').insertAfter($table);
      }
    });
  }
}

function zhb_topic_hide () {
    $('input.releaseName').each(function() {
      $(this).closest('tr').remove();
    });
    $('span.label.label-warning').each(function() {
      if ($(this).text() == '已被合并') $(this).closest('tr').remove();
    });
    $('ul.pagination').remove();
    var $thead = $('thead > tr').first().detach();
    $('thead').remove();
    var $tr = $('tr').detach();
    console.log('tr.size:',$tr.length);
    $tr.sort(function (a, b){
      return zhb_topic_sort_func(b) - zhb_topic_sort_func(a);
    });
    $thead.appendTo($('table tbody').first());
    $tr.appendTo($('table tbody').first());
}

var $btns = $('<div />')
  .attr('id','zhb-topic-remove-btns')
  .appendTo('body');

$('<div />')
  .attr('id','zhb-topic-remove-all-btn')
  .addClass('btn').addClass('btn-danger')
  .text('全部删除 ' + min_questions +'/'+ min_followers)
  .click(zhb_topic_remove_all)
  .appendTo($btns);

$('<div />')
  .attr('id','zhb-topic-remove-all-btn')
  .addClass('btn').addClass('btn-danger')
  .text('删除选中')
  .click(zhb_topic_remove_selected)
  .appendTo($btns);

$('<div />')
  .attr('id','zhb-topic-hide-btn')
  .addClass('btn').addClass('btn-default')
  .text('隐藏无效话题')
  .click(zhb_topic_hide)
  .appendTo($btns);

$('<div />')
  .attr('id','zhb-topic-remove-load-btn')
  .addClass('btn').addClass('btn-default')
  .text('加载' + max_pages + '页')
  .click(zhb_topic_remove_load)
  .appendTo($btns);
