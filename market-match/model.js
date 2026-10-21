/* Fictional teaching model. No network, browser history, identity or device inputs. */
(function(root){
'use strict';
const TOPICS=['music','cycling','coding','design'];
const PRODUCTS={headphones:{label:'Studio headphones',topic:'music'},bicycle:{label:'City bicycle',topic:'cycling'},course:{label:'Beginner coding course',topic:'coding'}};
const POLICIES={broad:'Broad campaign',context:'Contextual advertising',interest:'Consented interest targeting'};
const TRANSACTIONS=[
 {id:'equipment',item:'Workshop equipment',seller:'ForgeWorks Manufacturing Ltd',sellerRole:'business',buyer:'BrightLearn Schools Ltd — business office',buyerRole:'business',correct:'B2B',explanation:'Both seller and buyer are fictional businesses. The buyer is explicitly an education business buying equipment for its operations. A school office is not automatically a business: the purchaser’s role must be established.'},
 {id:'headphones',item:'Headphones',seller:'Sound Shelf shop',sellerRole:'business',buyer:'A household buying for personal use',buyerRole:'consumer',correct:'B2C',explanation:'The shop is a business; the household buys for personal use. The marketplace connects them but is not the item seller in this case.'},
 {id:'bicycle',item:'Used bicycle',seller:'An individual selling a personal bicycle',sellerRole:'consumer',buyer:'Another individual buying for personal use',buyerRole:'consumer',correct:'C2C',explanation:'Two individuals trade a personal item. A professional reseller would need a different classification. Being on a platform does not by itself make a sale C2C.'}
];
function profiles(){
 const rows=Array.from({length:20},(_,i)=>{
  const declared=TOPICS[i%4]; const inferred=i%5===0?TOPICS[(i+1)%4]:declared;
  return {id:`P${String(i+1).padStart(2,'0')}`,declared:[declared],page:TOPICS[(i+(i%3===0?1:0))%4],consent:i%3!==2,events:[{id:'E1',topic:inferred,deleted:false},{id:'E2',topic:inferred,deleted:false},{id:'E3',topic:TOPICS[(i+2)%4],deleted:false}]};
 });
 rows[3]={id:'P04',declared:['cycling'],page:'cycling',consent:true,events:[{id:'E1',topic:'music',deleted:false},{id:'E2',topic:'music',deleted:false},{id:'E3',topic:'design',deleted:false}],note:'The music browsing was research for a gift. The inferred preference is wrong in this fictional case.'};
 rows[8]={id:'P09',declared:['music'],page:'music',consent:false,events:[{id:'E1',topic:'music',deleted:false},{id:'E2',topic:'music',deleted:false},{id:'E3',topic:'coding',deleted:false}],note:'Refuses browsing-based targeting but is currently reading a music page. Contextual matching remains available.'};
 return rows;
}
function hash(text){let h=2166136261;for(const c of text){h^=c.charCodeAt(0);h=Math.imul(h,16777619);}return h>>>0;}
function draw(seed,id,product,kind){return hash(`${seed}:${id}:${product}:${kind}`)/4294967296;}
function infer(p){
 const counts=Object.fromEntries(TOPICS.map(t=>[t,0]));
 for(const e of p.events)if(!e.deleted)counts[e.topic]++;
 const topic=TOPICS.reduce((a,b)=>counts[b]>counts[a]?b:a,TOPICS[0]);
 return {topic,score:counts[topic],counts};
}
function fingerprint(audience){return hash(JSON.stringify(audience.map(p=>({id:p.id,declared:p.declared,page:p.page,consent:p.consent,events:p.events})))).toString(16);}
function run(audience,settings){
 if(!PRODUCTS[settings.product]||!POLICIES[settings.policy])throw Error('Unknown product or policy');
 const slots=Number(settings.slots); const seed=Number(settings.seed);
 if(!Number.isInteger(slots)||slots<1||slots>20||!Number.isInteger(seed)||seed<1||seed>9999)throw Error('Invalid experiment settings');
 const target=PRODUCTS[settings.product].topic;
 const results=audience.map(p=>{
  let eligible=false,reason='',inference=null,fields=[];
  if(settings.policy==='broad'){eligible=true;reason='Broad rule: every profile is eligible; no interest input is used.';}
  if(settings.policy==='context'){fields=['current page topic'];eligible=p.page===target;reason=`Current page ${p.page} ${eligible?'matches':'does not match'} ${target}. No browsing history is used.`;}
  if(settings.policy==='interest'){
   fields=['targeting consent'];
   if(!p.consent)reason='Targeting consent refused. Browsing topics are not read; this policy does not serve an ad.';
   else{
    fields.push(...p.events.filter(e=>!e.deleted).map(e=>`browsing ${e.id}.topic`));
    inference=infer(p);eligible=inference.topic===target&&inference.score>=2;
    reason=`Observed topics → inferred ${inference.topic} (${inference.score} events). Rule: inferred topic = ${target} AND score ≥ 2. ${eligible?'Eligible.':'Not eligible.'}`;
   }
  }
  return {id:p.id,declared:p.declared.slice(),page:p.page,consent:p.consent,inference,eligible,reason,fields,queue:hash(`${seed}:${p.id}:queue`),relevant:p.declared.includes(target),served:false,clicked:false,purchased:false,rank:null,clickDraw:draw(seed,p.id,settings.product,'click'),purchaseDraw:draw(seed,p.id,settings.product,'purchase')};
 });
 const ranked=results.filter(r=>r.eligible).sort((a,b)=>settings.policy==='interest'?(b.inference.score-a.inference.score||a.queue-b.queue||a.id.localeCompare(b.id)):(a.queue-b.queue||a.id.localeCompare(b.id)));
 ranked.forEach((r,i)=>{r.rank=i+1;r.served=i<slots;});
 for(const r of results){
  r.clickProbability=r.relevant?.55:.12;
  r.purchaseProbability=.30;
  r.clicked=r.served&&r.clickDraw<r.clickProbability;
  r.purchased=r.clicked&&r.purchaseDraw<r.purchaseProbability;
  r.missed=r.relevant&&!r.served;
  r.irrelevant=r.served&&!r.relevant;
  if(r.eligible)r.reason+=` Queue rank ${r.rank}; ${r.served?'within':'outside'} ${slots} available slots.`;
 }
 const metrics={eligible:ranked.length,served:results.filter(r=>r.served).length,relevant:results.filter(r=>r.served&&r.relevant).length,missed:results.filter(r=>r.missed).length,irrelevant:results.filter(r=>r.irrelevant).length,clicks:results.filter(r=>r.clicked).length,purchases:results.filter(r=>r.purchased).length,consentFields:results.reduce((n,r)=>n+r.fields.filter(f=>f==='targeting consent').length,0),browsingFields:results.reduce((n,r)=>n+r.fields.filter(f=>f.startsWith('browsing')).length,0),pageFields:results.reduce((n,r)=>n+r.fields.filter(f=>f==='current page topic').length,0)};
 metrics.fields=metrics.consentFields+metrics.browsingFields+metrics.pageFields;
 return {settings:{product:settings.product,policy:settings.policy,slots,seed},audienceFingerprint:fingerprint(audience),audience:JSON.parse(JSON.stringify(audience)),results,metrics};
}
function comparison(a,b){
 if(!a||!b)return {kind:'missing',message:'Run two experiments to compare.'};
 const sameProduct=a.settings.product===b.settings.product, sameAudience=a.audienceFingerprint===b.audienceFingerprint,sameSlots=a.settings.slots===b.settings.slots,sameSeed=a.settings.seed===b.settings.seed;
 if(sameProduct&&sameAudience&&sameSlots&&sameSeed&&a.settings.policy!==b.settings.policy)return {kind:'policy',message:'Policy comparison: same product, 20-profile audience state, slots and seed. Only the advertising policy changed.'};
 if(sameProduct&&!sameAudience&&sameSlots&&sameSeed&&a.settings.policy===b.settings.policy)return {kind:'input',message:'Changed-input experiment: same policy/product/slots/seed, with edited fictional consent or events. Explain the input change; this is not a policy-only comparison.'};
 if(sameProduct&&sameAudience&&sameSlots&&sameSeed)return {kind:'repeat',message:'Exact repeat: the displayed outcomes should be identical.'};
 return {kind:'mixed',message:'Several conditions changed. Do not attribute the difference to the policy alone. Hold product, audience state, slots and seed constant for a policy comparison.'};
}
const API={TOPICS,PRODUCTS,POLICIES,TRANSACTIONS,profiles,hash,draw,infer,fingerprint,run,comparison};
if(typeof module==='object'&&module.exports)module.exports=API;else root.MarketMatch=API;
})(typeof globalThis==='object'?globalThis:this);
