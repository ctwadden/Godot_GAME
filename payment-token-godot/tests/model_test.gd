extends SceneTree
const Lab=preload("res://scripts/lab.gd")
var failures=[]
func check(ok: bool,msg: String):
 if not ok:failures.append(msg);push_error(msg)
func _initialize():
 var r=Lab.run(1,1,0,true)
 check(r.totals.access==2,"Central digital-only normal: two have access")
 check(not r.rows[1].ok and not r.rows[2].ok,"No account and flat phone distinct barriers")
 check(r.rows[3].ok,"Accessible interface supports P04")
 check(Lab.run(1,1,0,false).totals.access==1,"Interface requirement changes model only")
 check(Lab.run(1,1,1,true).totals.access==0,"Central connection outage")
 check(Lab.run(1,2,1,true).totals.access==3,"Central outage does not disable shared route")
 check(Lab.run(1,1,2,true).totals.access==2,"Shared outage does not disable central route")
 check(Lab.run(0,1,3,true).totals.access==3,"Cash unaffected by internet")
 check(Lab.run(2,1,1,true).totals.access==3,"Mixed fallback during central outage")
 check(Lab.run(2,1,0,true).totals.access==4,"Mixed normal serves all with handling tradeoff")
 check(Lab.run(1,2,4,true).totals.access==3,"2-of-3 shared quorum works after one node lost")
 check(Lab.run(1,2,5,true).totals.access==0,"Quorum fails with two nodes lost")
 for policy in range(3):
  for route in [1,2]:
   for outage in range(6):
    var x=Lab.run(policy,route,outage,true)
    check(x==Lab.run(policy,route,outage,true),"Reproducible rules")
    for row in x.rows:
     var t=row.trace
     check(t.customer_before+t.shop_before==t.customer_after+t.shop_after+t.provider_after,"Balance conservation including provider fee")
     if not row.ok:check(t.fee==0 and t.customer_after==t.customer_before and t.fields.is_empty(),"Failure has no commit or charge")
     for field in t.fields:check(not field.contains("personal") and not field.contains("name"),"Only sanitized fake fields")
 check(Lab.image_bytes()==FileAccess.get_file_as_bytes("res://assets/harbour.svg"),"Copied byte payload equals actual original SVG file")
 var token=Lab.new_token()
 var licence=token.licence
 check(Lab.token_facts(token).copies==1,"One initial local file")
 Lab.copy_image(token)
 check(token.copies[0]==token.copies[1] and token.copies[1]==token.copies[2],"Same actual SVG bytes copied to three in-memory folders")
 check(Lab.fingerprint(token.copies[0])==Lab.fingerprint(token.copies[2]),"Content fingerprints agree")
 check(Lab.token_facts(token).registry_entries==1,"Copies do not duplicate unique token entry")
 Lab.transfer_token(token,"Alias B")
 check(token.controller=="Alias B" and token.id==Lab.TOKEN_ID,"Control changes; ID does not")
 check(token.licence==licence,"Transfer preserves explicit licence")
 check(not Lab.token_facts(token).commercial_permitted and Lab.token_facts(token).display_permitted,"Specified rights distinct")
 token.host_up=false
 check(not Lab.token_facts(token).remote_available and Lab.token_facts(token).local_available,"Broken remote link leaves local copy")
 check(token.history.size()==2 and token.id==Lab.TOKEN_ID,"Record persists when media unavailable")
 print("Payment/token model: %d failures" % failures.size());quit(1 if not failures.is_empty() else 0)
