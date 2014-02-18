var yt_current_time;

CL = {
        APPLICATION_ENV : "development"        
    };

function roundNumber(number, decimalPlaces) {
  decimalPlaces = (!decimalPlaces ? 2 : decimalPlaces);
  return Math.round(number * Math.pow(10, decimalPlaces)) /
      Math.pow(10, decimalPlaces);
}

/**
 * The 'getCurrentTime' function returns the elapsed time in seconds from
 * the beginning of the video. It calls player.getCurrentTime().
 * @return {number} The elapsed time, in seconds, of the playing video.
 */
function getCurrentTime() {
    if (yt_player && yt_player.getCurrentTime) {  
        
      var currentTime = yt_player.getCurrentTime();
      return roundNumber(currentTime, 3);
    }
}

function getDuration() {
    if (yt_player && yt_player.getDuration) {  
        
      var dur = yt_player.getDuration();
      return roundNumber(dur, 3);
    }
}


/**
 * The 'getPlayerState' function returns the status of the player.
 * @return {string} The current player's state -- e.g. 'playing', 'paused', etc.
 */
function getPlayerState() {
  if (yt_player && yt_player.getPlayerState) {
    var playerState = yt_player.getPlayerState();
    switch (playerState) {
      case 5:
        return 'video cued';
      case 3:
        return 'buffering';
      case 2:
        return 'paused';
      case 1:
        return 'playing';
      case 0:
        return 'ended';
      case -1:
        return 'unstarted';
      default:
        return 'Status uncertain';
    }
  }
}

//analytics - report how long user's watched this video/lesson.
var duration_watched = 0; //in milliseconds
var last_duration_reported = 0;
var reportInterval = 1000 * 30 ; //report time watched to server every 30 seconds

if (CL.APPLICATION_ENV == "development")
    reportInterval = 1000 * 3 ; //report time watched to server every 5
var analyticsRowId = '';

var reportToServer = function()
{
    
    if (last_duration_reported != duration_watched)
    {
        //based on duration_watched . Send analytics to server
        var d = {
                'lid' : CL.lesson_id,
                'course_id' : CL.course_id,
                'type' : 'watch',
                'id' : analyticsRowId,
                'duration' : duration_watched,
                'subject' : CL.subject,
                'st' : Math.round(new Date().getTime() / 1000) /* unix timestamp , started time*/
        };
        $.ajax({
            url : "/site/watch-analytics",
            dataType : 'JSON',
            data : d,
            success: function(data){
                if (data.success && analyticsRowId == '')
                {
                    analyticsRowId = data.result.id;
                }
                if (data.success)
                    last_duration_reported = duration_watched;
                
            }
        });
    }
    else 
    {
        console.log("duration unchanged");
    }

};
var start_analytics = function()
{
    //set interval every minute to update to the server
    setInterval(reportToServer, reportInterval);
};
/**
 * Youtube Js player so that we can track how many times
 * (or even what parts of the video) the student watches
 */
var yt_video_watched = false;
var report_watch_lesson ;
var no_yt_interval = false;
//setInterval interval for updating 
var updateInterval = 600; //milliseconds. //little more than half a second

var onYouTubeIframeAPIReady;
var yt_player_js_interval, update_playing_li,go_to_timeline,go_to_exercise, clear_yt_update_info_interval, start_yt_update_info_interval;
// Replace the 'ytplayer' element with an <iframe> and
// YouTube player after the API code downloads.
var yt_player, yt_seekto;
if (typeof js_ytid != 'undefined' )
{
      // Load the IFrame Player API code asynchronously.
      var tag = document.createElement('script');
      tag.src = "https://www.youtube.com/player_api";
      var firstScriptTag = document.getElementsByTagName('script')[0];
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
    
      // Replace the 'ytplayer' element with an <iframe> and
      // YouTube player after the API code downloads.
      var yt_player;
      onYouTubeIframeAPIReady = function() {
          yt_player = new YT.Player('ytplayer', {
            height: '450',
            width: '100%',
            playerVars: { 'autoplay': 0, 'controls': 1 , 'wmode' : 'opaque'},
            videoId: js_ytid,
            events: {
                'onReady': function(event){
                    yt_seekto = function(ts)
                    {
                        yt_player.seekTo(ts);
                        playerState = getPlayerState();
                        if (playerState != 'playing')
                            yt_player.playVideo();
                    };
                    $("#lesson-video-timeline").show();
                    /*
                    //if url is of the form : http://xx.com/lecture/123#!/video-lecture/2
                    // that is we want to jump to the 2nd element in the lesson timeline 
                    var url = window.location.hash.toString();
                    var tmp = url.split('#lecture/');
                    if (tmp.length > 1)
                    {
                        var jumpto = tmp[1];
                        alert(jumpto);
                        $("li.timeline-li:eq(" + jumpto + ") a").trigger('click');
                    }
                    */
                },
                //'onPlaybackQualityChange': function(event){},
                'onStateChange': function(event){
                    playerState = getPlayerState();
                    //console.log('playerstate=' + playerState);
                    if (playerState == 'playing' && !yt_video_watched)
                    {
                        //user has started watching video
                        //send to server to update his progress if we're not reviewing the course
                        if (typeof CL.course_id != 'undefined' && CL.course_id != '0')
                        {
                            yt_video_watched = true;
                            start_analytics();
                        }
                    }
                    
                    if (playerState == 'playing' )
                    {
                        //also start the timer
                        start_yt_update_info_interval();
                    }
                    else
                    {
                        if (playerState == 'paused' || playerState == 'ended' )
                        {
                            //console.log('-----------------clearing Inteval------------------');
                            clear_yt_update_info_interval();
                        }
                        if (playerState == 'ended')
                        {
                            //remove the .playing classes
                            $("#timeline-ul li").removeClass('playing');
                        }
                    }
                 },
                'onError': function(event){alert('Error loading youtube video');},
              }          
          });
    };         
};

function start_yt_update_info_interval()
{
    yt_player_js_interval = setInterval(updateytplayerInfo, updateInterval); 
    no_yt_interval = false;
    updateytplayerInfo();                        
}

function clear_yt_update_info_interval()
{
    clearInterval(yt_player_js_interval);
    no_yt_interval = true;
}

function updateytplayerInfo() {
    //console.log('updateytplayerInfo');
    if (no_yt_interval)
    {
        //console.log('no_yt_interval');
        return;
    }
  if (yt_player) {
      duration_watched = duration_watched + updateInterval;
      //console.log("new duration watched " + duration_watched);
      
      var st = 0; //start time
      var next_st = 0;
      yt_current_time = getCurrentTime();
      //var duration = yt_player.getDuration();
      //var player_state = getPlayerState();
      //find out in which range the yt_current_time is
      count = lesson_timeline.length;
      $currentlyPlaying = $("#timeline-ul li.playing");
      if ($currentlyPlaying.size() > 0)
      {
          st = $currentlyPlaying.attr('data-st');
          $next = $currentlyPlaying.next();
          if ($next.hasClass('timeline-li'))
          {
              next_st = $next.attr('data-st');
              
              if (yt_current_time > st && yt_current_time < next_st) //nothing changes. just return
              {
                  return;
              }
              else if (yt_current_time >= next_st)
              {
                  if ($currentlyPlaying.find('i.repeat').hasClass('repeat-disabled'))
                  {
                      $currentlyPlaying.find('i.repeat').hide();
                      $nextAnchor = $next.find('a');
                      if ($nextAnchor.hasClass('timeline-exercise-nav'))
                      {
                          $nextAnchor.trigger('click');
                      }
                      else 
                      {
                          //just updating the next player
                          update_playing_li($next);//.find('a').trigger('click');                      
                      }
                  }
                  else //repeat mode
                  {
                      $currentlyPlaying.trigger('click');
                  }
                  
                  return;
              }
          }
          else 
          {
              //$currentlyPlaying is the last
              //console.log('no next found');
              //next_st = duration;
              return;
          }
      }
      
      //nothing applicable. Perhaps it's the first time we're playing 
      //We must loop through the li here
      for (var i = 0; i < count; i++)
       {
          if (
                  lesson_timeline[i] <= yt_current_time && 
                  (i == count - 1 || ( i < count -1 && lesson_timeline[i+1] > yt_current_time))
             )
          {
              $li = $("#st-" +  lesson_timeline[i] );
              go_to_timeline($li.find('a'), false);
          }
       }
             
    }
}

$(document).ready(function(){
    update_playing_li = function($li)
    {
        $li.addClass('watched playing').siblings('.timeline-li').removeClass('playing');        
    };
    
    go_to_exercise = function($a)
    {
        //show exercise
        //stOP video
        if (yt_player)
        {
            yt_player.pauseVideo();
        }
        var exId = $a.attr('data-exid');
        
        $("#ytplayer").hide();
        $("#timeline-exercises").show();
        $("#timeline-exercises div.exercise").hide();
        $("#timeline-exercise-" + exId).show();
        
        switch_exercise(exId);
        update_playing_li($a.parent());
    };
    
    go_to_timeline = function($a, seek)
    {
        $("#ytplayer").show();
        $("#timeline-exercises").hide();
        update_playing_li($a.parent());
        if (seek)
        {
            var seekto = $a.parent().attr('data-st');
            //console.log('go_to_tl ' + seekto);
            yt_seekto(seekto);
        }
    };
    
    $("li.timeline-li a").click(function(e){
        //TODO: remove timer
        //console.log('clicked on .li a');
        clear_yt_update_info_interval();
        
        
        if ($(this).hasClass('timeline-exercise-nav'))
        {
            //console.log('going to exercise');
            go_to_exercise($(this));
        }
        else 
        {
            //console.log('going to timeline');
            go_to_timeline($(this), true);
        }
        e.preventDefault();
        return false;
    });
    
    //when an exercise is finished.
    $("a.finish-timeline-exercise").click(function(e){
        $("#st-" + $(this).attr('data-st')).addClass('watched');
        if ($(this).attr('data-next-st') != '')
        {
            tlNavLiId = "#st-" + $(this).attr('data-next-st');
            $(tlNavLiId).find('a').trigger('click');
        }
        /*
        e.preventDefault();
        return false;
        */
    });
    
    $("li.timeline-li").hover(
        function(){
            if (!$(this).hasClass('playing') && $(this).attr('data-type') == 'summary')
                $(this).find("i.repeat").show();
        },
        function(){
            if (!$(this).hasClass('playing') && $(this).attr('data-type') == 'summary'
                && $(this).find('i.repeat').hasClass('repeat-disabled')
            )
                $(this).find("i.repeat").hide();
        }
    );
    
    $("li.timeline-li i.repeat").click(function(e){
        $(this).toggleClass('repeat-disabled');
    });
    
});