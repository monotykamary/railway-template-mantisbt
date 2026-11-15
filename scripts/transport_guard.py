import re,urllib.parse
def health_ok(status,body):
 return status==200 and 'MantisBT' in body and 'login' in body.lower()
def redirect_ok(status,location,canonical):
 target=urllib.parse.urlsplit(location);expected=urllib.parse.urlsplit(canonical)
 return status in (301,302,303) and expected.scheme=='https' and target.scheme=='https' and target.netloc==expected.netloc and not target.username and target.path in ('/login_page.php','/my_view_page.php','/index.php')
def cookie_target_ok(base,target):
 a=urllib.parse.urlsplit(base);b=urllib.parse.urlsplit(target)
 return a.scheme=='http' and (a.scheme,a.netloc)==(b.scheme,b.netloc) and not b.username
def owned_url(base,path):
 if not path.startswith('/') or path.startswith('//') or '\\' in path:raise ValueError('nonlocal request path')
 result=base.rstrip('/')+path
 if not cookie_target_ok(base,result):raise ValueError('cross-origin request')
 return result
def original_view_ok(seed,body):
 if set(seed)!={'project','issue','note'} or any(type(v) is not int or v<=0 for v in seed.values()):return False
 title=re.search(r'<title[^>]*>(.*?)</title>',body,re.I|re.S)
 return bool(title and re.search(r'\b0*'+str(seed['issue'])+r':\s*Persistent maintenance issue',title.group(1)) and 'Original persistent note' in body and re.search(r'(?:id|name)=[\"\']c0*'+str(seed['note'])+r'[\"\']',body))
