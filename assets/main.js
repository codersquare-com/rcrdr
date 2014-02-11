var VietEDPlayer, init_handlers;
var init_sliders; //has to be separated from init_handlers because
var playingConversation = false;
var playDone;
//when the div is hidden, slider init wouldn't work

$(document).ready(function(){
        
     showMic = true;
     // ================================callback
     function thisMovie(movieName) {
         if (navigator.appName.indexOf("Microsoft") != -1) {
             return window[movieName];
         } else {
             return document[movieName];
         }
     }
     
     function minimizeFlash() {
        document.getElementById('flashWrapper').setAttribute("style","width:10px;height:10px;");
     }
     function maximizeFlash() {
         document.getElementById('flashWrapper').setAttribute("style","width:250px;height:250px;");
      }
      
    
      var log_string = function(txt)
      {
          var t = $("#log-textarea").text();
          t = t + "\n " + txt;
          $("#log-textarea").text(t);
          
      }

      var log = function(arguments)
      {
          var t = $("#log-textarea").text();
          for (var i = 0; i < arguments.length; i++) {
              log_string(arguments[i]);
          }
          log_string("=======");
      }
      var stop_recording_cb = function()
      {
          //$("#doneStep").trigger('click');
          $('#replayRecording').show();
          $("#saveRecording").show();
          $("#stopRecording").hide();
      }
      
      $('#clear_log').click(function(){
          $("#log-textarea").text('');
      });
      
      // js receive as function
     jsEventHandler = function() {
          log(arguments);
          if(arguments[0] == 'microphoneAccess')
          {
            if(arguments[1] == 'true' || arguments[1] === true)
            {
                //minimizeFlash();
                //log('showing actions');
                $('#record-area').show();
                init_sliders();
                $("#volumeWrapper").hide();
            }
            else 
            {
                maximizeFlash();
                $('#record-area').hide();
                //init_sliders();
                //$("#volumeWrapper").hide();
            }
          
          }
          else if (arguments[0] == 'flashLoaded')
          {
              VietEDPlayer = thisMovie("VietEDPlayer");
              init_handlers();
          }
          else if(arguments[0] == 'saveRecordingDone')
          {
              var filename = $("#recording_name").val();
              $(".recording[data-id='" + filename+ "']").removeClass('being_recorded').addClass('recorded');
              //var html = "<div><a class='recorded' name='" + filename + "' href='javascript:void(0);'>" + filename + "</a></div>";
              //$(html).insertAfter();
          }
          else if(arguments[0] == 'recordingTimeout')
          {
              stop_recording_cb();
          }
          else if(arguments[0] == 'playDone')
          {
          }
          
     }
    
     init_handlers = function()
     {
         playDone = function()
         {
             log_string('playDone');
             if (playingConversation)
             {
                 //console.log(123);
                 var $playing  = $("#conversation").find("span.playing").removeClass('playing');
                 var $next = $playing.nextAll(".recording").first();
                 $next.trigger('recording.play');   
             }
         }
         //button function
         $("#mic_setting").click(function()
         {
             if(showMic){         
                 maximizeFlash();
                 showMic = false;
                 thisMovie("VietEDPlayer").showMicrophone(-1);
             }
             /*
             else
                 {
                 minimizeFlash();
             }
             */
             //VietEDPlayer.recordClick();
         });
         
         $("span").bind('recording.play', function(){
             $(this).addClass('playing');
             
             var filename = $(this).attr('data-id');
             log_string('playing ' + filename);
             VietEDPlayer.play(filename, -1);
         });
         
         $(".recording").click(function(){
             $(".recording").removeClass('being_recorded');
             var $this = $(this);
             var filename = $this.attr('data-id');
             var dur = $this.attr('data-duration');
             if ($this.hasClass('recorded'))
             {
                 //play 
                 
                 if ($this.hasClass('is_playing'))
                 {
                     VietEDPlayer.pause_resume();
                     $this.removeClass('is_playing').addClass('paused');
                 }    
                 else if ($this.hasClass('paused')) 
                 {
                     VietEDPlayer.pause_resume();
                 }
                 else 
                 {
                     VietEDPlayer.play(filename, -1);
                 }
             }
             else 
             {
                 $("#recording_name").val(filename);
                 $("#recording_dur").val(dur);
                 $(this).addClass('being_recorded');
             }
         });

         $("#play_conversation").click(function(){
             playingConversation = true;
             $("#conversation .recording:eq(1)").trigger('recording.play'); 
         });
        
         $("#playURL").click(function(){
             var v = $("#sample_mp3").val();
             VietEDPlayer.play(v, -1);
             $(this).hide();
             $("#pauseURL, #stopURL").show(); 
         });

         $("#pauseURL").click(function(){
             //var v = $("#sample_mp3").val();
             VietEDPlayer.pause_resume();
             if ($(this).find('i').hasClass('glyphicon-pause'))
                 $(this).find('i').removeClass('glyphicon-pause').addClass('glyphicon-play');
             else 
                 $(this).find('i').removeClass('glyphicon-play').addClass('glyphicon-pause');
             
         });
 
         $("#stopURL").click(function(){
             //var v = $("#sample_mp3").val();
             VietEDPlayer.pause_resume();
             $("#playURL").show();
             $("#pauseURL, #stopURL").hide();
         });
 
         
         $("#startRecording").click(function(){
             //TODO : get this from the conversation annotation info
             var filename = $("#recording_name").val();
             var dur = $("#recording_dur").val();
             VietEDPlayer.startRecording(filename,dur);
             //TODO: make the recording button blinking
             //show other buttons
             $('#stopRecording').show();
             $('#replayRecording').hide();
         });

         $("#stopRecording").click(function(){
             VietEDPlayer.stopRecording();
             
             stop_recording_cb();
         })
         
         //stop recording
         $("#saveRecording").click(function(){
              VietEDPlayer.saveRecording();
         });
         
         $("#replayRecording").click(function(){
             VietEDPlayer.replayRecording();
         })

         /*
         $("#volumeInBtn").click(function()
         {
            VietEDPlayer.volumeIn($("#volumeIn").val());
         });
         
         $("#volumeOutBtn").click(function()
         {
            VietEDPlayer.volumeOut($("#volumeOut").val());
         });
         */

     }

     init_sliders = function()
     {
         $('#volumeIn').slider(
                 {
                     formater: function(value) {
                         VietEDPlayer.volumeIn(value);
                         log_string(value);
                         $('#volumeInValue').html(value);
                         return value + '%';
                       }
                 });

             $('#volumeOut').slider(
                     {
                     formater: function(value) {
                         VietEDPlayer.volumeOut(value);
                         log_string(value);
                         $('#volumeOutValue').html(value);
                         return value + '%';
                       }
                     }
               
             );
             
             $("#volumeToggler").click(function(){
                 $('#volumeWrapper').toggle();
             });
                      
         
     };
     //=================init
      minimizeFlash();
      

});
