#!/usr/bin/env python3
import os,re,requests
b=os.environ['BASE_URL'].rstrip('/');pw=os.environ['ADMIN_PASSWORD'];home=requests.get(b+'/login_page.php',timeout=30);assert home.status_code==200 and 'MantisBT' in home.text
def submit(password):
 s=requests.Session();g=s.get(b+'/login_page.php',timeout=30);t=re.search(r'name="login_token" value="([^"]+)"',g.text);assert t
 step=s.post(b+'/login_password_page.php',data={'return':'index.php','login_token':t.group(1),'username':'administrator'},allow_redirects=True,timeout=30);t2=re.search(r'name="login_token" value="([^"]+)"',step.text);assert t2
 login=s.post(b+'/login.php',data={'return':'index.php','login_token':t2.group(1),'username':'administrator','password':password,'secure_session':'on'},allow_redirects=True,timeout=30);return s,login
_,wrong=submit('wrong-password');assert 'login' in wrong.url or 'incorrect' in wrong.text.lower()
s,login=submit(pw);assert login.status_code==200 and ('my_view_page.php' in login.url or 'Logout' in login.text),login.url
blocked=requests.get(b+'/admin/install.php',timeout=30);assert blocked.status_code==404
print('MantisBT smoke checks passed')
