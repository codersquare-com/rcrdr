<?php
function t($x)
{
	return $x;
}
$mode = isset($_REQUEST['mode']) ? $_REQUEST['mode'] : 'yt';
$version = 'bin-debug'; //or bin-release
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!-- saved from url=(0014)about:internet -->
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en"> 
    <!-- 
    Smart developers always View Source. 
    
    This application was built using Adobe Flex, an open source framework
    for building rich Internet applications that get delivered via the
    Flash Player or to desktops via Adobe AIR. 
    
    Learn more about Flex at http://flex.org 
    // -->
    <head>
        <title></title>
        <meta name="google" value="notranslate" />         
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <!-- Include CSS to eliminate any default margins/padding and set the height of the html element and 
             the body element to 100%, because Firefox, or any Gecko based browser, interprets percentage as 
             the percentage of the height of its parent container, which has to be set explicitly.  Fix for
             Firefox 3.6 focus border issues.  Initially, don't display flashContent div so it won't show 
             if JavaScript disabled.
        -->
        <!-- Enable Browser History by replacing useBrowserHistory tokens with two hyphens -->
        <!-- BEGIN Browser History required section -->
        <link rel="stylesheet" type="text/css" href="<?php echo $version;?>/history/history.css" />
        <script type="text/javascript" src="<?php echo $version;?>/history/history.js"></script>
        <!-- END Browser History required section -->  
        <script type="text/javascript" src="<?php echo $version;?>/swfobject.js"></script>

        <script>
        var jsEventHandler;
        var conversationSource = '<?echo $mode;?>';
        </script>
        
        <script src="assets/jquery.js"></script>
    	<script src="assets/bootstrap-3.0.0/dist/js/bootstrap.min.js"></script>
    	
    	
    	<script src="assets/bootstrap-slider-1.9.5/js/bootstrap-slider.js"></script>
    	
		<link href="assets/bootstrap-3.0.0/dist/css/bootstrap.min.css" rel="stylesheet">			
    	<link rel="stylesheet" href="assets/bootstrap-slider-1.9.5/css/bootstrap-slider.css" />
    	<script src="assets/utils.js"></script>
        <script src="assets/main.js"></script>
        <link rel="stylesheet" type="text/css" href="assets/styles.css" />
            
    
        <script type="text/javascript">
            // For version detection, set to min. required Flash Player version, or 0 (or 0.0.0), for no version detection. 
            var swfVersionStr = "11.1.0";
            // To use express install, set to playerProductInstall.swf, otherwise the empty string. 
            var xiSwfUrlStr = "playerProductInstall.swf";
            var flashvars = {};
            var params = {};
            params.quality = "high";
            params.bgcolor = "#ffffff";
            params.allowscriptaccess = "always";
            params.allowfullscreen = "true";
            var attributes = {};
            attributes.id = "VietEDPlayer";
            attributes.name = "VietEDPlayer";
            attributes.align = "middle";
            swfobject.embedSWF(
                "<?php echo $version;?>/VietEDPlayer.swf", "flashContent", 
                "100%", "100%", 
                swfVersionStr, xiSwfUrlStr, 
                flashvars, params, attributes);
            // JavaScript enabled so display the flashContent div in case it is not replaced with a swf object.
            swfobject.createCSS("#flashContent", "display:block;text-align:left;");
        </script>
    </head>
    <body>
        <!-- SWFObject's dynamic embed method replaces this alternative HTML content with Flash content when enough 
             JavaScript and Flash plug-in support is available. The div is initially hidden so that it doesn't show
             when JavaScript is disabled.
        -->
        <div class='container'>
        	<div class='btn btn-group'>
	        	<a class='btn btn-default <?if ($mode == 'yt'):?>active<?endif;?>' href='index.php?mode=yt'>
	        	<?if ($mode == 'yt'):?><i class='glyphicon glyphicon-ok'></i><?endif;?>
	        	<i class='glyphicon glyphicon-play-circle'></i> Youtube impersonator</a>
	        	<a class='btn btn-default <?if ($mode == 'voice'):?>active<?endif;?>' href='index.php?mode=voice'>
	        	<?if ($mode == 'voice'):?><i class='glyphicon glyphicon-ok'></i><?endif;?>
	        	Voice Roleplay</a>
        	</div>
        </div>
        <div class='container'>
        <div><hr/></div>
        <div class='row' id='conversation'>
        	<div class='col-md-6' >
        		<?php 
/*        		
	            <div id='player-control'>
	            		<span class='scale'>00:00</span> 
	            		<input type="text"
	            				style='width:80%;'
										  id='playbackProgress' 
										  value="0" 
										  data-slider-min="0" 
										  data-slider-max="100" 
										  data-slider-step="1" 
										  data-slider-value="0" 
										  data-slider-orientation="horizontal" 
										  data-slider-selection="before"
										  data-slider-tooltip="show">		
			        	<span class='scale'>100%</span>      
	            </div>
*/	            
        		?>
				<div id='conversation-control' style='padding:10px;border:1px solid #eee;'>
					
					<span id='play-conversation-control'>
						<h4>Conversation</h4>
						
			            <a href='javascript:void(0);' class='btn btn-default' id='play_conversation'
			            style='color:green;'> <i class='glyphicon glyphicon-play'></i> Listen</a>

			            <a href='javascript:void(0);' class='btn btn-default' id='resume_conversation' 
			            style='display:none;'>
			            <i class='glyphicon glyphicon-play'></i> Play</a>
			            
			            <a href='javascript:void(0);' class='btn btn-default' id='pause_conversation' 
			            style='display:none;'>
			            <i class='glyphicon glyphicon-pause'></i> Pause</a>

			            <a class='btn btn-default' id='show-roleplay' 
			            	><i class='glyphicon glyphicon-ok'></i> RolePlay this conversation</a>
			            	
			           <br/>
			           
			           <input type='checkbox' checked='checked' name='show-transcript' 
			         		id='conversation-show-transcript'/> 
				         		<label for='conversation-show-transcript'>Show Transcript</label>
			         </span>
			         
			         <span id='roleplay-conversation-control' style='display:none;'>
			            <a class='btn btn-default' id='listen-conversation-again'  
			            	><i class='glyphicon glyphicon-arrow-left'></i> Listen again</a>
			            	
			         	<input type='checkbox' name='show-transcript' id='roleplay-show-transcript'
			         	<?if ($mode == 'yt'):?>checked='checked'<?endif;?>
			         	 /> 
				         		<label for='roleplay-show-transcript'>Show whole Transcript</label>
			         </span>   
	            </div>
	            
	            <div id='conversation-transcript'  class='well'>
					<? if ($mode == 'voice'):?>	            
						<div>
		            <!-- 
				            Intro: <span title='click to record' 
				            	class='recording' 
				            	data-id='test.mp3' 
				            	data-duration='120'
				            	data-role=''>
				            - Testing </span>
				            <br/>
				            
		             -->
				            Peter: <span title='click to record' 
				            	class='recording' 
				            	data-id='1' 
				            	data-duration='120'
				            	data-role='Peter'>
				            - Hello Mary</span>
				            <br/>
				            
				            Mary: 
				            <span title='click to record' 
				            	class='recording' 
				            	data-id='2' 
				            	data-duration='1000'
				            	data-role='Mary'>
				           		- Hello Peter, How are you?
				           	</span>
				            <br/>
				            
				            Peter: 
				            <span title='click to record' class='recording' data-id='3'  data-duration='5'
				            data-role='Peter'>
				            - Fine thank you, and you?
				            </span>
				            <br/>
				            
				            Mary: <span title='click to record' 
					            class='recording' 
					            data-id='4'
					            data-duration='5'
					            data-role='Mary'>
					            - That's great to hear
					         </span>
					         
		            </div>
		                    	
				    <?elseif ($mode == 'yt'):?>
	    		           <script>
					          var js_ytid = '1dk7VjKvrjc'; //Toan shinoda
					        </script>
				    		
		            		<div id="ytplayer" style='text-align:center;'>
						        <div style='margin-top:180px;font-size:150%;font-weight:bold;'>
						    		<i class='icon-spinner icon-spin'></i> 
						    		<?php echo t('loading_video_lecture', 1);?>
						             . <?php echo t('please_wait', 1);?>
								</div>
								<div>
						    		<?php echo t('if_you_cannot_see_it_after_a_while', 1)?> <a
						    			href='javascript:location.reload();' id='reload_yt'> <?php echo t('click_to_reload',1);?></a>
						        </div>
							</div>
				    <?endif;?>	       
			    </div>
			                 	
        		<div id='conversation-recorder' style='display:none;'>
        			<div>
			        	Choose role(s) you wanna play
			        </div>
			        			
        			<div id='availableRoles' class='well'>
        			</div>
        			<div>
        				Ready? <a href='javascript:void(0);' class='btn btn-default' id='startRoleplaying'
			         	   style='color:green;'>
			            <i class='glyphicon glyphicon-play'></i> <b>Start roleplaying</b></a>
			            <br/>
			            <br/>
        			</div>
        			
        			<div id='record-buttons' style='display:none;'>
	        			<div  class='well'>
	        				<span id='playingSentenceTranscript'>
	        				</span>
						</div>
						<div id='record-actions' style='text-align:center;'>
				            <span >
							    
<!-- 							    
							    <i title='Start recording' class='glyphicon glyphicon-record' style='color:red;'
				              	id='startRecording'>
				              	</i>
 -->				              	 
				              	<img src='assets/images/record.png' id='startRecording' alt='start recording' title='start recording' />
<!-- 				             	
				             	 	<i title='Stop recording' class='glyphicon glyphicon-stop' style='color:red;display:none;'
				              	id='stopRecording'></i> 
 -->				             	 
 								<img src='assets/images/is_recording.png' id='stopRecording' 
 								 alt='stop recording' title='stop recording'
 								style='display:none;'
 								/>

								<div>
								<i title='Replay last recording' class='glyphicon glyphicon-play' 
				             	 		style='display:none;'
				              	id='replayRecording'></i> 
				
				             	 	<i title='Save recording' class='glyphicon glyphicon-ok' style='color:green;display:none;'
				              	id='saveRecording'></i> 
								</div>				             	
				            </span>
						</div>
        			</div>
					
					<div id='replayRoleplayingWrapper' style='display:none;'>
						<div>
						Congratulations. You have finished your roleplaying...
						</div>
						
						<a href='javascript:void(0);' class='btn btn-default' id='replayRoleplaying'
			         	   style='color:green;'>
			            <i class='glyphicon glyphicon-play'></i> <b>Listen to your roleplaying</b></a>
					 </div>           
        		</div>
        	</div>
        	
        	<div class='col-md-3'>
        	<div id='roleplay-setting' style='display:none;'>
        		<?if ($mode == 'yt'):?>
        			Youtube transcript:
	        		<div id='yt-transcript'>
						<ul id="timeline-ul" style="padding-left: 5px;">
							<li class="timeline-li" data-st="1" data-type="summary" id="st-1"
								data-id='st-1'
								data-role='Mary-Youtuber'
							>
								<a class="seekto-nav text-muted" href="javascript:void(0);"> 
								<span style="font-weight:bold;" class="tl">00:01						
								</span> &nbsp;  Mary saying something											
								</a>  
							</li>
							<li class="timeline-li" data-st="05" data-type="summary" id="st-05"
							data-id='st-05'
							data-role='Peter-Youtuber'
							>
							<a class="seekto-nav text-muted" href="javascript:void(0);"> 
							<span style="font-weight:bold;" class="tl">00:05
							</span> &nbsp;  Peter saying something											
							</a>  
								</li>
								
							<li class="timeline-li" data-st="06" data-type="summary" id="st-06"
								data-id='st-06'
								data-role='Mary-Youtuber'
							>
								<a class="seekto-nav text-muted" href="javascript:void(0);"> 
								<span style="font-weight:bold;" class="tl">00:06						
								</span> &nbsp;  Mary saying something 2											
								</a>  
							</li>
							
							<li class="timeline-li" data-st="10" data-type="summary" id="st-10"
							data-id='st-10'
							data-role='Peter-Youtuber'
							>
							<a class="seekto-nav text-muted" href="javascript:void(0);"> 
							<span style="font-weight:bold;" class="tl">00:10
							</span> &nbsp;  Peter saying something 2											
							</a>  
								</li>
								
						</ul>
	   				</div>
	   				<div style='min-height:50px;'>
	   				Youtube logging
	   				<a href='javascript:void(0);' id='yt-get-elapsed-time'>yt-get-elapsed-time</a>
	   				</div>
    			<?endif;?>
    			
					<div class="panel panel-default">
					  <div class="panel-heading">Difficulty settings</div>
					  <div class="panel-body">
					    <div class="btn-group btn-group-justified" id='difficult-setting-btns'>
        			    	<a href="javascript:void(0);" 
        			    		class="btn btn-primary active "
        			    		data-difficulty='easy'
        			    		> Easy </a>
        			    	<a href="javascript:void(0);"
        			    		class="btn btn-primary"
        			    		data-difficulty='difficult' 
        			    		> Difficult</a>
        			    </div>
						
						<div id='setting-tmp'>
							<div id='easy-setting' style=''>
								- Show transcript
								<br/>
								- Pause and record
							</div>
							
							<div id='difficult-setting' style='display:none'>
								- No transcript
								<br/>
								- Continuous conversation
							</div>
						</div>
						
						
						<a href='javascript:void(0);' class='toggle-dom' target-id='difficulty-setting-customized, #setting-tmp'>Customized Settings</a>
						
        				<div class='well' id='difficulty-setting-customized' style='display:none;'>
        					<div>
				         	<input type='checkbox' name='roleplay-show-sentence-transcript' checked='checked' id='roleplay-show-sentence-transcript'/> 
				         		<label for='roleplay-show-sentence-transcript'>Show Transcript when speaking</label>
        					</div>
							
							<div>
							Speaking Speed
							<br/>
						       <select id='speaking-speed' class='form-control'>
								   	<option value='slow'>-- Slow . You can listen to your saying first before next -- </option>
								   	<option value='fast'>-- Fast . No re-listen. Just flowing. Hardcore only -- </option>
							   </select>				         		
							</div>
				         		
				        
				         		
						<div style='display:none;'>
							Speaking Speed
							<br/>
						       <select id='pause-period' class='form-control'>
								   	<option value='0'>-- Fast . No pause between sentences -- </option>
								   	<option value='1'>-- Pause 1 second between every sentence -- </option>
							   </select>				         		
							</div>
        				</div>
					  </div>
					</div>
						
        			</div>
        			
					<div>
					<div class="panel panel-default">
					  <div class="panel-heading">Recorder settings</div>
					  <div class="panel-body">
					              <div id='volumeToggler'>
					              	<a href='javascript:void(0);'>Settings</a>
					              	<br/><br/>
					              </div>
					              <div id='volumeWrapper'>
					              	<div>
					                	<i title='Mic volume' class='glyphicon glyphicon-volume-up'
					                	 style='color:green;'></i> 
					                	 <span class='scale' id='volumeInValue'>0</span><span class='scale'>%</span>  
					                
										<input type="text"
										  id='volumeIn' 
										  value="90" 
										  data-slider-min="0" 
										  data-slider-max="100" 
										  data-slider-step="1" 
										  data-slider-value="90" 
										  data-slider-orientation="horizontal" 
										  data-slider-selection="before"
										  data-slider-tooltip="show">		
							        	<span class='scale'>100</span>      
							        </div>
									<div style='min-height:30px'></div>
					              	<div>
					                	<i title='Sound volume' class='glyphicon glyphicon-headphones'
					                	 style='color:green;'></i> 
					                	 <span class='scale' id='volumeOutValue'>0</span><span class='scale'>%</span>  
					                
										<input type="text"
										  id='volumeOut' 
										  value="100" 
										  data-slider-min="0" 
										  data-slider-max="100" 
										  data-slider-step="1" 
										  data-slider-value="100" 
										  data-slider-orientation="horizontal" 
										  data-slider-selection="before"
										  data-slider-tooltip="show">		
										<span class='scale'>100</span>            
						        	</div>
						        	</div>
						        	</div> <!-- volumeToggler -->
						        </div>
				        </div>
        	</div>
        	<div class='col-md-3'>
        	     <h4>AS Logs</h4>
        	     <a href='javascript:void(0);' id='get_recording' >Upload mp3</a>					              
        	     <br/>
        	     <a href='javascript:void(0);' class='clear_log'>Clear logs</a>
		         <textarea id='log-textarea' style='width:100%;' rows="20" name="output" ></textarea>
		         <a href='javascript:void(0);' class='clear_log'>Clear logs</a>
        	
        	</div>
        </div>
        <div class='row'>
        	<hr/>
        </div>
        <div class='row'>

        <div class='col-md-6'>
            <h3>Flash .swf file area</h3>
            <div id ="flashWrapper" style="width:200px; height:150px;" >
                <div id="flashContent" >
                    <p>
                        To view this page ensure that Adobe Flash Player version 
                        11.1.0 or greater is installed. 
                    </p>
                    <script type="text/javascript"> 
                        var pageHost = ((document.location.protocol == "https:") ? "https://" : "http://"); 
                        document.write("<a href='http://www.adobe.com/go/getflashplayer'><img src='" 
                                        + pageHost + "www.adobe.com/images/shared/download_buttons/get_flash_player.gif' alt='Get Adobe Flash player' /></a>" ); 
                    </script> 
                </div>
            </div>
            
           
        </div>
        
        <div class='col-md-6'>
        <div class='row'>
	           <div class='col-md-6'>
		          <h3> JS control </h3>
		          <div id='js-control' class='well'>
		            <div id='form-player'>
		               <h4>Player area</h4>
		              <input type="text" name="input" value="bin-debug/1.mp3" id='sample_mp3'/>         
		              
		              <a class='btn btn-primary' id='playURL'><i class='glyphicon glyphicon-play'></i></a>
		              <a class='btn btn-primary' id='pauseURL' style='display:none;'><i class='glyphicon glyphicon-pause'></i></a> 
		              <a class='btn btn-primary' id='stopURL' style='display:none;color:red;'><i class='glyphicon glyphicon-stop'></i></a> 
		              		
		           </div>
		           <hr/>
		           <div>
			           <a href='javascript:void(0);' class='btn btn-sm btn-primary' id='mic_setting'>
			           Mic Access Permissions</a>
			           
		           </div>
		           
		           <div style='min-height:20px;'></div>
		           <div id='record-area' style='display:none;'>
		              
		              <div>
		              	<h4>Recorder area </h4>               
				              <h5>Sample recording file settings </h5>
				                File name<br/>
				              <input type="text" name="input1" value="name" id='recording_name'/>
				              <br/>
				                Max Duration (seconds)<br/>              
				              <input type="text" name="input2" value="120" id='recording_dur' />
				              <br/>
				              
				              
					</div>						       
					<div>
						<h3>Actions</h3>
							<div>
<hr/>
<div>					              
					              6. <input type="button" class='btn' value="user: Play All recordings" id='play' /><br />
</div>
							</div>
					</div>
		           </div><!--record-area-->
		          </div>
	          </div>
	          <div id="right-col" class='col-md-6'>
	          </div>
	     	
     	   </div>
     	</div>
        <noscript>
            <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="100%" 
            	height="100%" id="VietEDPlayer">
                <param name="movie" value="VietEDPlayer.swf" />
                <param name="quality" value="high" />
                <param name="bgcolor" value="#ffffff" />
                <param name="allowScriptAccess" value="sameDomain" />
                <param name="allowFullScreen" value="true" />
                <!--[if !IE]>-->
                <object type="application/x-shockwave-flash" data="VietEDPlayer.swf" width="100%" height="100%">
                    <param name="quality" value="high" />
                    <param name="bgcolor" value="#ffffff" />
                    <param name="allowScriptAccess" value="sameDomain" />
                    <param name="allowFullScreen" value="true" />
                <!--<![endif]-->
                <!--[if gte IE 6]>-->
                    <p> 
                        Either scripts and active content are not permitted to run or Adobe Flash Player version
                        11.1.0 or greater is not installed.
                    </p>
                <!--<![endif]-->
                    <a href="http://www.adobe.com/go/getflashplayer">
                        <img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash Player" />
                    </a>
                <!--[if !IE]>-->
                </object>
                <!--<![endif]-->
            </object>
        </noscript>
        
        </div></div>     
   </body>
   <? if ($mode == 'yt'):?>
        <script src="assets/yt.js"></script>
        <script src="assets/yt-recorder.js"></script>
	<?endif;?>   
</html>
