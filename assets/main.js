var volumeIn, volumeOut, VietEDPlayer;

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
     
     VietEDPlayer = thisMovie("VietEDPlayer");
     
     function pageInit() {
        document.getElementById('flashWrapper').setAttribute("style","width:10px;height:10px;");
     }
    
     // butoon function
     $("#mic_setting").click(function()
     {
         if(showMic){         
             document.getElementById('flashWrapper').setAttribute("style","width:250px;height:250px;");
             showMic = false;
         }
         VietEDPlayer.recordClick();
     });
     
    
     $("#recordDone").click(function(){
         VietEDPlayer.recordDoneClick();
     })
     
     $("#play").click(function(){
         VietEDPlayer.playClick();
     })
    
     $("#replay").click(function(){
         VietEDPlayer.replayClick();
     })
     
     $("#playURL").click(function(){
         var v = $("#sample_mp3").val();
         VietEDPlayer.playURL(v);
     });
     
     $("#doneStep").click(
             function(){
                 VietEDPlayer.doneStep();
                 
     });
     
     $("#start_recording").click(function(){
         var filename = $("#recording_name").val();
         var dur = $("#recording_dur").val();
         VietEDPlayer.recordSound(filename,dur);
     });
    
     
     $("#volumeInBtn").click(function()
     {
        VietEDPlayer.volumeIn($("#volumeIn").val());
     });
     
     $("#volumeOutBtn").click(function()
             {
                VietEDPlayer.volumeOut($("#volumeOut").val());
             });
    
    
      var log = function(arguments)
      {
          console.log(arguments);
          var t = $("#log-textarea").text();
          for (var i = 0; i < arguments.length; i++) {
              t+= "ActionScript says: " + arguments[i] + "\n";
          }
          $("#log-textarea").text(t);
          
      }
    
      // js receive as function
     jsEventHandler = function() {
         console.log('213');
         log(arguments);
          if(arguments[0] == 'microphoneAccess' && arguments[1] == 'true')
            pageInit();    
     }
    
     
     //=================init
      pageInit();
});
