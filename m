From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: net-i40e: Reconsider further usage of variable "i" in
 i40e_vc_get_vf_resources_msg()
Date: Fri, 8 Jan 2016 20:51:40 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFE3115@fmsmsx115.amr.corp.intel.com>
References: <566ABCD9.1060404@users.sourceforge.net>
 <56868E0B.5040602@users.sourceforge.net>
 <5686925F.5020508@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <5686925F.5020508@users.sourceforge.net>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiBGcm9tOiBTRiBNYXJrdXMgRWxmcmluZyBbbWFpbHRvOmVsZnJpbmdAdXNlcnMuc291cmNlZm9y
Z2UubmV0XQ0KPiANCj4gSGVsbG8sDQo+IA0KPiBJIGhhdmUgdGFrZW4gYW5vdGhlciBsb29rIGF0
IHRoZSBpbXBsZW1lbnRhdGlvbiBvZiB0aGUNCj4gZnVuY3Rpb24gImk0MGVfdmNfZ2V0X3ZmX3Jl
c291cmNlc19tc2ciLiBJIGZpbmQgdGhlIHVzZSBvZiB0aGUgdmFyaWFibGUNCj4gImkiDQo+IHN0
cmFuZ2UgdGhlcmUuIEl0IHNlZW1zIHRoYXQgdGhlIHZhbHVlIGZyb20gdGhlIGluY3JlbWVudCBv
cGVyYXRpb24gaW4NCj4gYW4NCj4gaWYgYnJhbmNoIGlzIG5vdCByZXVzZWQgc28gZmFyLg0KPiAN
Cj4gSSB3b3VsZCBhcHByZWNpYXRlIGEgZnVydGhlciBjbGFyaWZpY2F0aW9uLg0KPiBDYW4gdGhp
cyB2YXJpYWJsZSBiZSBldmVudHVhbGx5IGRlbGV0ZWQ/DQoNClRoYW5rcyBmb3IgcG9pbnRpbmcg
dGhpcyBvdXQuICBXZSd2ZSBnb3QgYW4gaW50ZXJuYWwgcGF0Y2ggY29taW5nIHRoYXQgd2lsbCBh
ZGRyZXNzIHRoaXMuDQoNCkNoZWVycywNCnNsbg0K
