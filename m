From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [PATCH] net-i40e: Replace variable initialisations by
 assignments in i40e_vc_get_vf_resources_msg()
Date: Thu, 7 Jan 2016 22:43:20 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFE2AAD@fmsmsx115.amr.corp.intel.com>
References: <566ABCD9.1060404@users.sourceforge.net>
 <56868E0B.5040602@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: LKML <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56868E0B.5040602@users.sourceforge.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiBGcm9tOiBTRiBNYXJrdXMgRWxmcmluZyBbbWFpbHRvOmVsZnJpbmdAdXNlcnMuc291cmNlZm9y
Z2UubmV0XQ0KPiBTZW50OiBGcmlkYXksIEphbnVhcnkgMDEsIDIwMTYgNjozMyBBTQ0KPiANCj4g
RnJvbTogTWFya3VzIEVsZnJpbmcgPGVsZnJpbmdAdXNlcnMuc291cmNlZm9yZ2UubmV0Pg0KPiBE
YXRlOiBGcmksIDEgSmFuIDIwMTYgMTU6MTE6MDkgKzAxMDANCj4gDQo+IFJlcGxhY2UgZXhwbGlj
aXQgaW5pdGlhbGlzYXRpb25zIGZvciBmb3VyIGxvY2FsIHZhcmlhYmxlcyBhdCB0aGUgYmVnaW5u
aW5nDQo+IGJ5IGFzc2lnbm1lbnRzIHRoYXQgd2lsbCBvbmx5IGJlIHBlcmZvcm1lZCBpZiB0aGUg
Y29ycmVzcG9uZGluZyBjb2RlDQo+IHdpbGwgcmVhbGx5IGJlIGV4ZWN1dGVkLg0KPiANCj4gU2ln
bmVkLW9mZi1ieTogTWFya3VzIEVsZnJpbmcgPGVsZnJpbmdAdXNlcnMuc291cmNlZm9yZ2UubmV0
Pg0KPiAtLS0NCg0KVGhpcyBzZWVtcyB0byBtZSB0byBiZSB1bm5lY2Vzc2FyeSBmdXNzaW5nIHdp
dGggdGhlIGNvZGUuDQoNCnNsbg0KDQo=
