From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next 05/14 v2] i40evf: fix up strings in init task
Date: Thu, 20 Feb 2014 16:20:32 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D6551AB30@FMSMSX113.amr.corp.intel.com>
References: <1392868178-7011-1-git-send-email-aaron.f.brown@intel.com>
	 <1392868178-7011-2-git-send-email-aaron.f.brown@intel.com>
	 <1392869350.24844.22.camel@joe-AO722> <1392871887.2629.10.camel@localhost>
	 <1392872294.24844.25.camel@joe-AO722> <1392873372.2629.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>,
	Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48469 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755284AbaBTQVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Feb 2014 11:21:00 -0500
In-Reply-To: <1392873372.2629.13.camel@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogQnJvd24sIEFhcm9uIEYN
Cj4gU2VudDogV2VkbmVzZGF5LCBGZWJydWFyeSAxOSwgMjAxNCA5OjE2IFBNDQo+IFRvOiBKb2Ug
UGVyY2hlcw0KPiBDYzogZGF2ZW1AZGF2ZW1sb2Z0Lm5ldDsgV2lsbGlhbXMsIE1pdGNoIEE7IG5l
dGRldkB2Z2VyLmtlcm5lbC5vcmc7DQo+IGdvc3BvQHJlZGhhdC5jb207IHNhc3NtYW5uQHJlZGhh
dC5jb207IEJyYW5kZWJ1cmcsIEplc3NlDQo+IFN1YmplY3Q6IFJlOiBbbmV0LW5leHQgMDUvMTQg
djJdIGk0MGV2ZjogZml4IHVwIHN0cmluZ3MgaW4gaW5pdCB0YXNrDQo+IA0KPiBPbiBXZWQsIDIw
MTQtMDItMTkgYXQgMjA6NTggLTA4MDAsIEpvZSBQZXJjaGVzIHdyb3RlOg0KPiA+IE9uIFdlZCwg
MjAxNC0wMi0xOSBhdCAyMDo1MSAtMDgwMCwgQWFyb24gQnJvd24gd3JvdGU6DQo+ID4gPiBPbiBX
ZWQsIDIwMTQtMDItMTkgYXQgMjA6MDkgLTA4MDAsIEpvZSBQZXJjaGVzIHdyb3RlOg0KPiA+ID4g
PiBPbiBXZWQsIDIwMTQtMDItMTkgYXQgMTk6NDkgLTA4MDAsIEFhcm9uIEJyb3duIHdyb3RlOg0K
PiA+ID4gPiA+IE1ha2Ugc3VyZSBlcnJvcnMgYXJlIHJlcG9ydGVkIGF0IHRoZSBjb3JyZWN0IGxv
ZyBsZXZlbCwgcXVpdA0KPiBwcmludGluZw0KPiA+ID4gPiA+IHRoZSBmdW5jdGlvbiBuYW1lIGV2
ZXJ5IHRpbWUsIGFuZCBtYWtlIHRoZSBtZXNzYWdlcyBtb3JlIGNvbnNpc3RlbnQNCj4gaW4NCj4g
PiA+ID4gPiBmb3JtYXQuDQo+ID4gPiA+IFtdDQo+ID4gPiA+ID4gZGlmZiAtLWdpdCBhL2RyaXZl
cnMvbmV0L2V0aGVybmV0L2ludGVsL2k0MGV2Zi9pNDBldmZfbWFpbi5jDQo+IGIvZHJpdmVycy9u
ZXQvZXRoZXJuZXQvaW50ZWwvaTQwZXZmL2k0MGV2Zl9tYWluLmMNCj4gPiBbXQ0KPiA+ID4gPiAr
CQlkZXZfaW5mbygmcGRldi0+ZGV2LCAiSW52YWxpZCBNQUMgYWRkcmVzcyAlcE1BQywgdXNpbmcN
Cj4gcmFuZG9tXG4iLA0KPiA+ID4gPiA+ICsJCQkgYWRhcHRlci0+aHcubWFjLmFkZHIpOw0KPiA+
ID4gPiBUaGUgIkFDIiBhZnRlciAlcE0gaXMgc3VwZXJmbHVvdXMuDQo+ID4gPiBUaGFua3MgSm9l
LCBndWVzcyBJJ2xsIGJlIG1ha2luZyBhbm90aGVyIHNwaW4uLi4NCj4gPg0KPiA+IE9yIHNlbmQg
YW5vdGhlciBwYXRjaCBhZnRlciB0aGlzIG9uZSBiZWNhdXNlIHRoZXJlDQo+ID4gYXJlIDIgJXBN
QUMgdXNlcyBpbiBpNDBldmZfbWFpbi5jDQo+IA0KPiBUaGF0IHdvcmtzLiAgSSdsbCBidWcgTWl0
Y2ggdG8gbG9vayBmb3IgdGhlbSB3aGVuIGhlIGRvZXMgYSBodW50IGZvciBvdGhlcg0KPiBPT00g
bWVzc2FnZXMgdGhhdCBoZSBzYWlkIGhlJ2QgZG8gYW5kIHNlbmQgdGhlbSB1cCBsYXRlci4gIFNv
IEkgZ3Vlc3MgdGhpcw0KPiBwYXRjaCBjYW4gc3RhbmQgZm9yIG5vdy4NCj4gDQoNCkFkZGVkIGl0
IHRvIG15IHRvLWRvIGxpc3QuIFRoYW5rcyBhZ2FpbiwgSm9lLg0KDQotTWl0Y2gNCg0K
