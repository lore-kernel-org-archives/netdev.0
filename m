From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [net-next 09/17] fm10k: trivial fixup message style to include
 a colon
Date: Tue, 16 Jun 2015 20:33:42 +0000
Message-ID: <1434486822.12272.2.camel@intel.com>
References: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1434462448-140563-10-git-send-email-jeffrey.t.kirsher@intel.com>
	 <55802FB2.9080507@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "nhorman@redhat.com" <nhorman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: "sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:46470 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757513AbbFPUeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 16:34:05 -0400
In-Reply-To: <55802FB2.9080507@cogentembedded.com>
Content-Language: en-US
Content-ID: <55F464D12D293147B7E83258103F24F9@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDE1LTA2LTE2IGF0IDE3OjE2ICswMzAwLCBTZXJnZWkgU2h0eWx5b3Ygd3JvdGU6
DQo+IEhlbGxvLg0KPiANCj4gT24gNi8xNi8yMDE1IDQ6NDcgUE0sIEplZmYgS2lyc2hlciB3cm90
ZToNCj4gDQo+ID4gRnJvbTogSmFjb2IgS2VsbGVyIDxqYWNvYi5lLmtlbGxlckBpbnRlbC5jb20+
DQo+IA0KPiA+IEZpeCB1cCBlcnJvciBtZXNzYWdlIHN0eWxlIHRvIGluY2x1ZGUgYSBjb2xvbi4N
Cj4gDQo+ID4gU2lnbmVkLW9mZi1ieTogSmFjb2IgS2VsbGVyIDxqYWNvYi5lLmtlbGxlckBpbnRl
bC5jb20+DQo+ID4gVGVzdGVkLWJ5OiBLcmlzaG5laWwgU2luZ2ggPEtyaXNobmVpbC5rLnNpbmdo
QGludGVsLmNvbT4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBKZWZmIEtpcnNoZXIgPGplZmZyZXkudC5r
aXJzaGVyQGludGVsLmNvbT4NCj4gPiAtLS0NCj4gPiAgIGRyaXZlcnMvbmV0L2V0aGVybmV0L2lu
dGVsL2ZtMTBrL2ZtMTBrX3BjaS5jIHwgMiArLQ0KPiA+ICAgMSBmaWxlIGNoYW5nZWQsIDEgaW5z
ZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pDQo+IA0KPiA+IGRpZmYgLS1naXQgYS9kcml2ZXJzL25l
dC9ldGhlcm5ldC9pbnRlbC9mbTEway9mbTEwa19wY2kuYyANCj4gPiBiL2RyaXZlcnMvbmV0L2V0
aGVybmV0L2ludGVsL2ZtMTBrL2ZtMTBrX3BjaS5jDQo+ID4gaW5kZXggNDQ1MDE0YS4uNTI2OWIx
NiAxMDA2NDQNCj4gPiAtLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9mbTEway9mbTEw
a19wY2kuYw0KPiA+ICsrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2ZtMTBrL2ZtMTBr
X3BjaS5jDQo+ID4gQEAgLTE3NzMsNyArMTc3Myw3IEBAIHN0YXRpYyBpbnQgZm0xMGtfcHJvYmUo
c3RydWN0IHBjaV9kZXYgKnBkZXYsDQo+ID4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgZm0xMGtfZHJpdmVyX25hbWUpOw0KPiA+ICAgICBpZiAoZXJyKSB7DQo+ID4gICAg
ICAgICAgICAgZGV2X2VycigmcGRldi0+ZGV2LA0KPiA+IC0gICAgICAgICAgICAgICAgICAgInBj
aV9yZXF1ZXN0X3NlbGVjdGVkX3JlZ2lvbnMgZmFpbGVkIA0KPiA+IDB4JXhcbiIsIGVycik7DQo+
ID4gKyAgICAgICAgICAgICAgICAgICAicGNpX3JlcXVlc3Rfc2VsZWN0ZWRfcmVnaW9ucyBmYWls
ZWQ6IA0KPiA+IDB4JXhcbiIsIGVycik7DQo+IA0KPiAgICAgSSBkb24ndCB0aGluayBwcmludGlu
ZyBlcnJvciBpbiBoZXhhZGVjaW1hbCBtYWtlcyBtdWNoIHNlbnNlLCBzbyANCj4geW91IG1pZ2h0
IA0KPiBhcyB3ZWxsIGZpeCB0aGF0IGZvcm1hdCB0byAiJWQiLi4uDQo+IA0KPiBXQlIsIFNlcmdl
aQ0KPiANCg0KU3VyZSB0aGluZy4NCg0KUmVnYXJkcywNCkpha2U=
