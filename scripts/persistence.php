<?php
function mantis_can_seed($exists,$project_id) { return !$exists && ($project_id === 0 || $project_id === false); }
function mantis_positive_id($value) { return (is_int($value) || (is_string($value) && ctype_digit($value))) && (int)$value>0; }
function mantis_record_valid($p,$b,$note_id,$note_issue,$text) {
 foreach(['project','issue','note'] as $key) if(!isset($p[$key]) || !mantis_positive_id($p[$key]))return false;
 return (int)$b->id===(int)$p['issue'] && (int)$b->project_id===(int)$p['project'] && (int)$note_id===(int)$p['note'] && (int)$note_issue===(int)$p['issue'] && $b->summary==='Persistent maintenance issue' && $b->description==='Must survive upgrade and redeploy' && $text==='Original persistent note';
}
if(defined('MANTIS_GUARD_TEST_ONLY'))return;
// Mantis 2.28.4 API contracts reviewed against immutable upstream source.
define('CLI', true); require '/var/www/html/core.php';
require_api('project_api.php');require_api('bug_api.php');require_api('bugnote_api.php');require_api('category_api.php');
if(auth_attempt_script_login('administrator',getenv('MANTIS_ADMIN_PASSWORD'))!==true)throw new Exception('admin auth failed');
$path='/var/www/html/config/railway-product-proof.json';$phase=getenv('SMOKE_PHASE');
if($phase==='boot') {
 if(!mantis_can_seed(file_exists($path),project_get_id_by_name('Railway persistence proof')))throw new Exception('boot must be pristine');
 $project=project_create('Railway persistence proof','Upgrade validation',10,VS_PUBLIC);
 if(!mantis_positive_id($project))throw new Exception('invalid created project id');
 $categories=category_get_all_rows($project);if(!$categories)throw new Exception('no inherited category');
 $category=(int)$categories[0]['id'];if(!mantis_positive_id($category))throw new Exception('invalid category');
 $bug=new BugData();$bug->project_id=$project;$bug->reporter_id=auth_get_current_user_id();$bug->category_id=$category;
 $bug->summary='Persistent maintenance issue';$bug->description='Must survive upgrade and redeploy';
 $bug->reproducibility=10;$bug->severity=50;$bug->priority=30;$bug->view_state=VS_PUBLIC;
 $id=$bug->create();if(!mantis_positive_id($id))throw new Exception('invalid issue id');
 $note=bugnote_add($id,'Original persistent note','0:00',false,BUGNOTE,'',null,false);
 if(!mantis_positive_id($note))throw new Exception('invalid note id');
 file_put_contents($path,json_encode(['project'=>(int)$project,'issue'=>(int)$id,'note'=>(int)$note]));
}elseif(!file_exists($path))throw new Exception('missing original proof; refusing recreation');
$p=json_decode(file_get_contents($path),true,512,JSON_THROW_ON_ERROR);
$b=bug_get($p['issue'],true);
if(!mantis_record_valid($p,$b,$p['note'],bugnote_get_field($p['note'],'bug_id'),bugnote_get_text($p['note'])))throw new Exception('original issue/note identity or content changed');
echo json_encode(['phase'=>$phase,'issue'=>(int)$b->id,'project'=>(int)$b->project_id,'note'=>(int)$p['note'],'verified'=>true])."\n";
