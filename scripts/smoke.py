#!/usr/bin/env python3
"""Mantis server auth only: exact-worker cookie replay; never follow redirects."""
import os,re,json,urllib.request,urllib.error,urllib.parse,http.cookiejar
from transport_guard import owned_url, cookie_target_ok, original_view_ok
base=os.environ['BASE_URL'].rstrip('/');origin=urllib.parse.urlsplit(base);assert origin.scheme=='http'
class NoRedirect(urllib.request.HTTPRedirectHandler):
 def redirect_request(self,*args,**kwargs):return None
def flow(password):
 jar=http.cookiejar.CookieJar();opener=urllib.request.build_opener(NoRedirect(),urllib.request.HTTPCookieProcessor(jar))
 def req(path,data=None):
  url=owned_url(base,path)
  assert cookie_target_ok(base,url), 'refusing cross-origin cookie forwarding'
  # Preserve every cookie attribute in jar; only explicit same-origin HTTP replay.
  header='; '.join(c.name+'='+c.value for c in jar if c.value)
  r=urllib.request.Request(url,data=urllib.parse.urlencode(data).encode() if data else None,headers={'Cookie':header} if header else {})
  try:response=opener.open(r,timeout=30)
  except urllib.error.HTTPError as e:response=e
  return response.status,response.read().decode(),response.headers
 status,html,_=req('/login_page.php');assert status==200 and 'MantisBT' in html
 token=re.search(r'name="login_token" value="([^"]+)"',html);assert token
 status,html,_=req('/login_password_page.php',{'return':'my_view_page.php','login_token':token.group(1),'username':'administrator'});assert status==200
 token=re.search(r'name="login_token" value="([^"]+)"',html);assert token
 status,html,headers=req('/login.php',{'return':'my_view_page.php','login_token':token.group(1),'username':'administrator','password':password,'secure_session':'on'})
 return req,status,html,headers,jar
bad,status,html,headers,jar=flow('invalid-proof-password')
status,html,_=bad('/my_view_page.php');assert status in (301,302,303) and 'Logout' not in html
req,status,html,headers,jar=flow(os.environ['ADMIN_PASSWORD']);assert status in (301,302,303)
assert any(c.secure for c in jar), 'secure session requested; preserve Secure attribute'
status,html,_=req('/my_view_page.php');assert status==200 and ('Logout' in html or 'logout_page.php' in html)
seed=json.loads(os.environ['MANTIS_SEED_JSON'])
status,view,_=req('/view.php?id='+str(seed['issue']))
assert status==200 and original_view_ok(seed,view), 'original issue/note missing or wrong'
status,_,_=req('/admin/install.php');assert status==404
print(json.dumps({'phase':os.environ['SMOKE_PHASE'],'authenticated_dashboard':True,'installer_blocked':True,'server_auth_only':True,'browser_secure_cookie_verified':False,'tls_verified':False}))
