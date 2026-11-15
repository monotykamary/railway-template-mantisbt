<?php
// Run inside the app container; uses Mantis application APIs, never direct DB inserts.
define('CLI', true);
require '/var/www/html/core.php';
require_api('project_api.php');
require_api('bug_api.php');
require_api('bugnote_api.php');
if (!auth_attempt_script_login('administrator', getenv('MANTIS_ADMIN_PASSWORD'))) throw new Exception('admin auth failed');
$path='/var/www/html/config/railway-product-proof.json';
$phase=getenv('SMOKE_PHASE');
if ($phase === 'boot') {
 if (file_exists($path) || project_get_id_by_name('Railway persistence proof') !== false) throw new Exception('boot must be pristine');
 $project=project_create('Railway persistence proof', 'Upgrade validation', 10, VS_PUBLIC);
 $bug=new BugData(); $bug->project_id=$project; $bug->reporter_id=auth_get_current_user_id();
 $bug->summary='Persistent maintenance issue'; $bug->description='Must survive upgrade and redeploy';
 $bug->category_id=1; $bug->reproducibility=10; $bug->severity=50; $bug->priority=30; $bug->view_state=VS_PUBLIC;
 $id=$bug->create(); $note=bugnote_add($id, 'Original persistent note');
 if (!$id || !$note) throw new Exception('seed failed');
 file_put_contents($path,json_encode(['project'=>$project,'issue'=>$id,'note'=>$note]));
} else { if (!file_exists($path)) throw new Exception('missing original proof; refusing recreation'); }
$p=json_decode(file_get_contents($path),true,512,JSON_THROW_ON_ERROR);
$b=bug_get($p['issue']);
if ($b->summary!=='Persistent maintenance issue' || $b->description!=='Must survive upgrade and redeploy' || $b->project_id!=$p['project']) throw new Exception('issue changed or missing');
if (bugnote_get_text($p['note'])!=='Original persistent note') throw new Exception('note changed or missing');
echo json_encode(['phase'=>$phase,'issue'=>$p['issue'],'project'=>$p['project'],'note'=>$p['note'],'verified'=>true])."\n";
