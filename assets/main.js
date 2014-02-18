var VietEDPlayer, init_handlers;
var init_sliders; //has to be separated from init_handlers because
var playingMode = -1;
var playDone, pushSounds;
var availableRoles = [];
var chosenRoles = [];
//when the div is hidden, slider init wouldn't work
//var SOUND_CDN = "http://mp3.vieted.com/"
//var SOUND_CDN = "http://vieted.com/tmp/";
var SOUND_CDN = "http://192.168.2.103/";
var recording_dur = 3; //seconds
var recording_name = 'sample';
var speakingSpeed = 'slow';
var current_recording_playing = -1;
var waitingForUserToStartSpeaking = false;
var log_string;
var playFile;

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
      
    
      log_string = function(txt)
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
          log_string("===" + recording_name + "====" + recording_dur + "======");
      }
      
      var stop_recording_cb = function()
      {
          //$("#doneStep").trigger('click');
          if (speakingSpeed == 'fast')
          {
              $("#saveRecording").trigger('click');
              $("#stopRecording").hide();
          }
          else 
          {
              waitingForUserToStartSpeaking = true;
              $('#replayRecording, #saveRecording, #startRecording').show();
              $("#stopRecording").hide();
          }
      }
      
      $('.clear_log').click(function(){
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
                setCookie('mic_setting', 1);
                $('#record-area').show();
                init_sliders();
                //$("#volumeWrapper").hide();
            }
            else 
            {
                setCookie('mic_setting', 0);
                maximizeFlash();
                $('#record-area').hide();
                //init_sliders();
                //$("#volumeWrapper").hide();
            }
          
          }
          else if (arguments[0] == 'flashLoaded')
          {
              VietEDPlayer = thisMovie("VietEDPlayer");
              VietEDPlayer.stop = function(){
                  VietEDPlayer.pause_resume();
              };
              init_handlers();
              //TODO: if get_cookie
              if (getCookie('mic_setting') == 1)
              {
                    $("#mic_setting").trigger('click');
              }
          }
          else if(arguments[0] == 'saveRecordingDone')
          {
              /*
              var filename = $("#recording_name").val();
              $(".recording[data-id='" + filename+ "']").removeClass('being_recorded').addClass('recorded');
              //var html = "<div><a class='recorded' name='" + filename + "' href='javascript:void(0);'>" + filename + "</a></div>";
              //$(html).insertAfter();
              */
              if (playingMode == 'rolePlaying')
              {
                  //
                  playDone();
              }
          }
          else if(arguments[0] == 'recordingTimeout')
          {
              stop_recording_cb();
          }
          else if(arguments[0] == 'playDone')
          {
              //moved separately into playDone callback
          }
          
     }
    
     init_handlers = function()
     {
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

         playFile = function(filename)
         {
             //if file is remote
             if (filename.indexOf('http://') === 0)
                 VietEDPlayer.play(filename, -1);
             else 
                 VietEDPlayer.play(SOUND_CDN + filename, -1);
         }
         
         playDone = function()
         {
             $("#playingSentenceTranscript").html('');
             var $playing = $("#conversation").find("span.playing").removeClass('playing');
             if (playingMode == 'playingConversation' || playingMode == 'rolePlaying'
                 || playingMode == 'replayRoleplaying'
             )
             {
                 var $nexts = $playing.nextAll(".recording");
                 if ($nexts.size() > 0)
                 {
                     //TODO
                     $nexts.first().trigger('recording.play');
                 }
                 else //End of conversation 
                 {
                     if (playingMode == 'rolePlaying')
                     {
                         $("#replayRoleplayingWrapper").show();
                         $("#record-actions").hide();
                     }
                     else if (playingMode == 'playingConversation')
                     {
                         $("#play_conversation").show();
                         $("#resume_conversation, #pause_conversation").hide();
                     }
                     playingMode = -1 ;//playingConversation = false;
                 }
                 
             }
         }
         
         // custom event to automatically play
         // play 
         $("span.recording").bind('recording.play', function(){
             var $this = $(this);
             
             $this.addClass('playing');
             if (playingMode !== 'rolePlaying')
             {
                 $("#playingSentenceTranscript").html($this.html());
             }
             
             var filename = $this.attr('data-id');
             current_recording_playing = filename;
             
             if (playingMode == 'playingConversation')
             {
                 playFile(filename);
             }
             else if (playingMode == 'replayRoleplaying')
             {
                 var role = $this.attr('data-role');
                 if ($.inArray(role, chosenRoles) != -1)
                 {
                     //play user's recording
                     VietEDPlayer.play(filename, -1);
                 }
                 else 
                 {
                     playFile(filename);
                 }
             }
             else if (playingMode == 'rolePlaying')
             {
                 log_string('triggered.....');
                 //TODO: play the sound if it's not the chosen roles
                 var role = $this.attr('data-role');
                 if (role && $.inArray(role, chosenRoles) != -1)
                 {
                     waitingForUserToStartSpeaking = false;
                     //start the record button
                     recording_name = $this.attr('data-id');
                     recording_dur = $this.attr('data-duration');
                     
                     $("#record-actions").show();
                     
                     //trigger the record button
                     if (speakingSpeed == 'fast')
                         $("#startRecording").trigger('click');
                     else 
                     {
                         waitingForUserToStartSpeaking = true;
                         $("#startRecording").show();
                         $("#stopRecording, #saveRecording, #replayRecording").hide();
                     }
                     
                     if ($("#roleplay-show-sentence-transcript").is(":checked"))
                         $("#playingSentenceTranscript").html($this.html()).addClass('userInput');
                     else 
                         $("#playingSentenceTranscript").html("Please speak now").addClass('userInput');
                     
                     //$("#stopRecording").show();
                 }
                 else 
                 {
                     $("#record-actions").hide();
                     playFile(filename);

                     if ($("#roleplay-show-sentence-transcript").is(":checked"))
                         $("#playingSentenceTranscript").html($this.html()).removeClass('userInput');
                     else 
                         $("#playingSentenceTranscript").html("").removeClass('userInput');

                 }
             }
                 
         });
         
         $("#replayRoleplaying").click(function(){
             playingMode = 'replayRoleplaying';
             $("#conversation .recording:eq(0)").trigger('recording.play'); 
             //$(this).hide();
             //$("#pause_conversation").show();
         });

         
         
         //TODO: remove this when flow is done. This is only used
         // temporarily
         $(".recording").click(function(){
             //WHen everything is fresh. Clicking on 1 sentence will
             // play it and following sentences
             if (playingMode == -1)
             {
                 $("#play_conversation").hide();
                 $("#pause_conversation").show();
                 playingMode = 'playingConversation';
             }
             
             if (playingMode == 'playingConversation')
             {
                 $("#conversation").find("span.playing").removeClass('playing');
             }
             $(this).trigger('recording.play');
             /*
             else 
             {
                 
             }
             */
         })
         
         /*******************************PAGE 1***************************/
         $("#play_conversation").click(function(){
             playingMode = 'playingConversation';
             $("#conversation .recording:eq(0)").trigger('recording.play'); 
             $(this).hide();
             $("#pause_conversation").show();
         });
         
         $("#pause_conversation").click(function(){
             VietEDPlayer.pause_resume();
             $(this).hide();
             $("#resume_conversation").show();    
         });

         $("#resume_conversation").click(function(){
             //VietEDPlayer.pause_resume();
             $("#conversation .recording[data-id='" + current_recording_playing + "']").trigger('recording.play');
             //VietEDPlayer.pause_resume();
             //VietEDPlayer.play();
             $(this).hide();
             $("#pause_conversation").show();    
         });
         
         /* Start role playing */
         $("#startRoleplaying").on("click", function(){
             //TODO: VietEDPlayer.stop() here
             VietEDPlayer.stop();
             chosenRoles = [];
             $("#availableRoles").find(":checked").each(function(){
                 chosenRoles.push($(this).attr('data-role')); 
             });
             if (chosenRoles.length == 0)
             {
                 alert("Please choose at least 1 role first");
             }
             else 
             {
                 $("#record-buttons").show();
                 playingMode = 'rolePlaying';
                 $("#conversation .recording:eq(0)").trigger('recording.play');
             }
         });         
         
         $("#show-roleplay").click(function(){
             VietEDPlayer.stop();
             $("#play-conversation-control").fadeOut(function(){
                 if ($("#roleplay-show-transcript").is(":checked"))
                 {
                     $("#conversation-transcript").show();
                 }
                 else 
                     $("#conversation-transcript").hide();
                 
                 $("#roleplay-conversation-control").show();
                 $("#conversation-recorder").fadeIn();
                 $("#roleplay-setting").show();
            });
         });

         $("#listen-conversation-again").click(function(){
             $("#conversation-recorder").fadeOut(function(){
                 if ($("#conversation-show-transcript").is(":checked"))
                 {
                     $("#conversation-transcript").show();
                 }
                 else 
                     $("#conversation-transcript").hide();
                 
                 $("#play-conversation-control").fadeIn();
                 $("#roleplay-conversation-control").hide();
                 $("#play_conversation").trigger('click');
             });
         });
         
         $("#conversation-show-transcript, #roleplay-show-transcript").click(function(){
             $("#conversation-transcript").toggle();
         });
         
         /*
         $(".recording").click(function(){
             
             $(".recording").removeClass('being_recorded');
             var $this = $(this);
             var filename = $this.attr('data-id');
             var dur = $this.attr('data-duration');
                              $("#recording_name").val(filename);
                 $("#recording_dur").val(dur);

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
         */

         /*************************PAGE 2*****************************/
         $("html").keydown(function(event){
             log_string(event.which);
             if (event.which == 32 && playingMode == 'rolePlaying'
                 //Make sure only trigger if it is recording
             )
             {
                 if (speakingSpeed == 'slow' && waitingForUserToStartSpeaking)
                 {
                     $("#startRecording").trigger('click');
                 }
                 else 
                     $("#stopRecording").trigger('click');
                 
                 event.preventDefault();
                 return false;
             }
             else if (playingMode == 'rolePlaying' && speakingSpeed == 'slow')
             {
                 if (event.which == 83 ) /*S*/
                 {
                     //user pressed "saved"
                     $("#saveRecording").trigger('click');
                 }

                 else if (event.which == 82 ) /*R*/
                 {
                     //user pressed "saved"
                     $("#replayRecording").trigger('click');
                 }
                 
                 event.preventDefault();
                 return false;

             }
             
         });
         
         $("#recording_name").change(function(){
             recording_name = $("#recording_name").val();
         });
         $("#recording_dur").change(function(){
             recording_dur = $("#recording_dur").val();
         });
         
         $("#difficult-setting-btns a").click(function()
         {
             $("#difficult-setting-btns a").removeClass('active');
             $(this).addClass('active');
             var diff = $(this).attr('data-difficulty');
             if (diff == 'easy')
             {
                 $("#easy-setting").show();
                 $("#difficult-setting").hide();
                 $("#speaking-speed").val('slow').trigger('change');
                 $("#roleplay-show-sentence-transcript").attr("checked", "checked");
             }
             else if (diff == 'difficult')
             {
                 $("#easy-setting").hide();
                 $("#difficult-setting").show();
                 $("#speaking-speed").val('fast').trigger('change');
                 $("#roleplay-show-sentence-transcript").attr("checked", false);
             }
             
         });
         
         $("#speaking-speed").change(function(){
             speakingSpeed = $(this).val();
             //alert("startRecording clicked");
             if (speakingSpeed == 'fast')
                 $("#startRecording").hide();
             else
                 $("#startRecording").show();
         }).trigger('change');
         //var dur = $("#recording_dur").val();

         $("#startRecording").on("click", function(){
             waitingForUserToStartSpeaking = false;
             VietEDPlayer.startRecording(recording_name,recording_dur);
             $('#stopRecording').show();
             $('#replayRecording,#saveRecording, #startRecording').hide();
             
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
         
         /*** Play Mp3 ****/
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
         
         pushSounds = function(data)
         {
             log_string('pushSounds');
             console.log(data);
             $.ajax({
                 type : "POST",
                 url : "upload.php", 
                 data : {
                     mp3 : JSON.stringify(data)
                 },
                 success : function(d){
                     console.log(d);
                 }
             });
         }
         
         $("#get_recording").click(function(){
             VietEDPlayer.getSounds(["2.mp3"]);
         });
     } //init_handlers

     $('#playbackProgress').slider(
             {
                 formater: function(value) {
                     //VietEDPlayer.volumeIn(value);
                     //$('#volumeInValue').html(value);
                     //TODO: return to seconds
                     return value + '%';
                   }
             });
     
     init_sliders = function()
     {
         $('#volumeIn').slider(
                 {
                     formater: function(value) {
                         VietEDPlayer.volumeIn(value);
                         $('#volumeInValue').html(value);
                         return value + '%';
                       }
                 });

             $('#volumeOut').slider(
                     {
                     formater: function(value) {
                         VietEDPlayer.volumeOut(value);
                         $('#volumeOutValue').html(value);
                         return value + '%';
                       }
                     }
               
             );
             
             $("#volumeToggler").click(function(){
                 $('#volumeWrapper').toggle();
             });
                      
         
     };
     
     /***********************pre-populate roles ***************/
     var tmp1 ;
     if (conversationSource == 'voice')
     {
         $tmp1 = $("span.recording");
     }
     else //playing conversation youtube
     {
         $tmp1 = $("#timeline-ul li");
     }
     
     $tmp1.each(function(){
         var role = $(this).attr('data-role');
         if (role)
         {
                 availableRoles.push(role);
         }
     });
     $.unique(availableRoles);
     
     $.each(availableRoles, function(i,e){
         var html = "<input type='checkbox' name='roles[]' data-role='" + e + "' id='roles-" + e + "-element'/> " +
         "<label for='roles-" + e + "-element'>" + e + "</label>" +  
         "<br/>";
         //$(html).insertAfter($("#availableRoles"));
         $("#availableRoles").append(html);
     });
     
     //=================init
      minimizeFlash();
      

});
