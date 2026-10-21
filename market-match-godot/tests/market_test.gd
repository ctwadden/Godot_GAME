extends SceneTree
const M=preload("res://scripts/market.gd")
var failures=[]
func check(ok: bool, message: String):
 if not ok: failures.append(message);push_error(message)
func _initialize():
 var people=M.profiles()
 check(people.size()==20,"20 synthetic profiles")
 var broad=M.run(people,0,0)
 var context=M.run(people,0,1)
 var interest=M.run(people,0,2)
 check(broad.metrics.served==10 and broad.metrics.relevant==1,"Broad expected result")
 check(context.metrics.served==4 and context.metrics.relevant==3,"Context expected result")
 check(interest.metrics.served==5 and interest.metrics.relevant==3,"Interest expected result")
 check(broad.metrics.fields==0 and context.metrics.fields==20 and interest.metrics.fields==62,"Field accounting")
 check(interest.results[3].served and not interest.results[3].relevant,"Wrong inference represented")
 check(not interest.results[8].served and context.results[8].served,"Opt out still allows context")
 check(interest==M.run(people,0,2),"Repeatable outcomes")
 check(M.comparison(broad,interest)=="policy","Policy controlled comparison")
 people[3].events[0]=""
 var edited=M.run(people,0,2)
 check(not edited.results[3].eligible,"Deletion changes eligibility")
 check(M.comparison(interest,edited)=="input","Input comparison distinct")
 check(interest.audience[3].events[0]=="music","History snapshot preserved and labelled")
 people[3].consent=false
 var withdrawn=M.run(people,0,2)
 check(withdrawn.results[3].fields.size()==1 and withdrawn.results[3].inference.is_empty(),"Withdrawn consent prevents browsing reads")
 var clicks_without_purchase=0
 for product in range(3):
  for policy in range(3):
   for seed in [1,23,9999]:
    var r=M.run(M.profiles(),product,policy,5,seed)
    check(r.metrics.served<=5,"Slots respected")
    for out in r.results:
     check(out.clicked==(out.served and out.click_draw<out.click_probability),"Click rule")
     check(out.purchased==(out.clicked and out.purchase_draw<0.30),"Purchase rule")
     if out.clicked and not out.purchased: clicks_without_purchase+=1
 check(clicks_without_purchase>0,"Clicks do not guarantee purchases")
 print("Market model: %d failures" % failures.size())
 quit(1 if failures.size()>0 else 0)
