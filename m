From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 17:58:39 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F07712C197C5@SHSMSX103.ccr.corp.intel.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
 <20160718151841.GA19066@breakpoint.cc>
 <37D7C6CF3E00A74B8858931C1DB2F07712C1968E@SHSMSX103.ccr.corp.intel.com>
 <CALx6S36vLAEN-ezqm7EHwwGE876troCkDkkQKhsmeTc4VH0E9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Florian Westphal <fw@strlen.de>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"keescook@chromium.org" <keescook@chromium.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"gorcunov@openvz.org" <gorcunov@openvz.org>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"aduyck@mirantis.com" <aduyck@mirantis.com>,
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALx6S36vLAEN-ezqm7EHwwGE876troCkDkkQKhsmeTc4VH0E9w@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQoNCj4gT24gTW9uLCBKdWwgMTgsIDIwMTYgYXQgNTo1MSBQTSwgTGlhbmcsIEthbiA8a2FuLmxp
YW5nQGludGVsLmNvbT4gd3JvdGU6DQo+ID4NCj4gPg0KPiA+PiA+DQo+ID4+ID4gSXQgaXMgYSBi
aWcgY2hhbGxlbmdlIHRvIGdldCBnb29kIG5ldHdvcmsgcGVyZm9ybWFuY2UuIEZpcnN0LCB0aGUN
Cj4gPj4gPiBuZXR3b3JrIHBlcmZvcm1hbmNlIGlzIG5vdCBnb29kIHdpdGggZGVmYXVsdCBzeXN0
ZW0gc2V0dGluZ3MuDQo+ID4+ID4gU2Vjb25kLCBpdCBpcyB0b28gZGlmZmljdWx0IHRvIGRvIGF1
dG9tYXRpYyB0dW5pbmcgZm9yIGFsbCBwb3NzaWJsZQ0KPiA+PiA+IHdvcmtsb2Fkcywgc2luY2Ug
d29ya2xvYWRzIGhhdmUgZGlmZmVyZW50IHJlcXVpcmVtZW50cy4gU29tZQ0KPiA+PiA+IHdvcmts
b2FkcyBtYXkgd2FudA0KPiA+PiBoaWdoIHRocm91Z2hwdXQuDQo+ID4+DQo+ID4+IFNlZW1zIHlv
dSBkaWQgbG90cyBvZiB0ZXN0cyB0byBmaW5kIG9wdGltYWwgc2V0dGluZ3MgZm9yIGEgZ2l2ZW4g
YmFzZSBwb2xpY3kuDQo+ID4+DQo+ID4gWWVzLiBDdXJyZW50IHRlc3Qgb25seSBiYXNlIG9uIElu
dGVsIGk0MGUgZHJpdmVyLiBUaGUgb3B0aW1hbCBzZXR0aW5ncw0KPiA+IHNob3VsZCB2YXJ5IGZv
ciBvdGhlciBkZXZpY2VzLiBCdXQgYWRkaW5nIHNldHRpbmdzIGZvciBuZXcgZGV2aWNlIGlzIG5v
dA0KPiBoYXJkLg0KPiA+DQo+IFRoZSBvcHRpbWFsIHNldHRpbmdzIGFyZSB2ZXJ5IGRlcGVuZGVu
dCBvbiBzeXN0ZW0gYXJjaGl0ZWN0dXJlIChOVU1BDQo+IGNvbmZpZywgI2NwdXMsIG1lbW9yeSwg
ZXRjLikgYW5kIHNvbWV0aW1lcyBrZXJuZWwgdmVyc2lvbiBhcyB3ZWxsLiBBDQo+IGRhdGFiYXNl
IHRoYXQgcHJvdmlkZXMgYmVzdCBjb25maWd1cmF0aW9ucyBhY3Jvc3MgZGlmZmVyZW50IGRldmlj
ZXMsDQo+IGFyY2hpdGVjdHVyZXMsIGFuZCBrZXJuZWwgdmVyc2lvbiBtaWdodCBiZSBpbnRlcmVz
dGluZzsgYnV0IGJld2FyZSB0aGF0IHRoYXQgaXMNCj4gYSB3aG9sZSBidW5jaCBvZiB3b3JrIHRv
IG1haW50YWluLCBFaXRoZXIgd2F5IHBvbGljeSBsaWtlIHRoaXMgcmVhbGx5IHNob3VsZA0KPiBi
ZSBoYW5kbGVkIGluIHVzZXJzcGFjZS4NCg0KVGhlIGV4cHJlc3Npb24gIm9wdGltYWwiIEkgdXNl
ZCBoZXJlIGlzIG5vdCBhY2N1cmF0ZS4gU29ycnkgZm9yIHRoYXQuDQpUaGUgTkVUIHBvbGljeSB0
cmllcyB0byBnZXQgZ29vZCAobmVhciBvcHRpbWFsKSBwZXJmb3JtYW5jZSBieSB2ZXJ5DQpzaW1w
bGUgY29uZmlndXJhdGlvbi4NCkkgYWdyZWUgdGhhdCB0aGVyZSBhcmUgbG90cyBvZiBkZXBlbmRl
bmNpZXMgZm9yIHRoZSBvcHRpbWFsIHNldHRpbmdzLg0KQnV0IG1vc3Qgb2YgdGhlIHNldHRpbmdz
IHNob3VsZCBiZSB2ZXJ5IHNpbWlsYXIuIFRoZSBuZWFyIG9wdGltYWwgcGVyZm9ybWFuY2UNCmJ5
IGFwcGx5aW5nIHRob3NlIGNvbW1vbiBzZXR0aW5ncyBhcmUgZ29vZCBlbm91Z2ggZm9yIG1vc3Qg
dXNlcnMuIA0KV2UgZG9uJ3QgbmVlZCB0byBtYWludGFpbiBhIGRhdGFiYXNlIGZvciBjb25maWd1
cmF0aW9ucyBhY3Jvc3MNCmRldmljZXMvYXJjaGl0ZWN0dXJlcy9rZXJuZWwgdmVyc2lvbi4uLg0K
DQpUaGFua3MsDQpLYW4NCg==
