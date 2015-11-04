From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [PATCH v5] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Wed, 4 Nov 2015 22:53:05 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFAEA1A@fmsmsx115.amr.corp.intel.com>
References: <20151104193956.GD14575@oracle.com>
 <CAHp75Vcrx+Rkz2mDSG+GEUW6LdO0w6On=6UoV4fhZK27Ayf1zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: Andy Shevchenko <andy.shevchenko@gmail.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75Vcrx+Rkz2mDSG+GEUW6LdO0w6On=6UoV4fhZK27Ayf1zQ@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiBGcm9tOiBBbmR5IFNoZXZjaGVua28gW21haWx0bzphbmR5LnNoZXZjaGVua29AZ21haWwuY29t
XQ0KPiBTZW50OiBXZWRuZXNkYXksIE5vdmVtYmVyIDA0LCAyMDE1IDExOjU5IEFNDQo+IA0KPiBP
biBXZWQsIE5vdiA0LCAyMDE1IGF0IDk6MzkgUE0sIFNvd21pbmkgVmFyYWRoYW4NCj4gPHNvd21p
bmkudmFyYWRoYW5Ab3JhY2xlLmNvbT4gd3JvdGU6DQo+ID4NCj4gPiBUaGlzIGlzIHRoZSBpNDBl
IGVxdWl2YWxlbnQgb2YgY29tbWl0IGM3NjJkZmYyNGMwNiAoIml4Z2JlOiBMb29rIHVwIE1BQw0K
PiA+IGFkZHJlc3MgaW4gT3BlbiBGaXJtd2FyZSBvciBJRFBST00iKS4NCg0KWy4uLl0NCg0KPiA+
ICsgICAgICAgfQ0KPiA+ICsNCj4gPiArICAgICAgIG1lbXNldCgmZWxlbWVudCwgMCwgc2l6ZW9m
KGVsZW1lbnQpKTsNCj4gPiArICAgICAgIGV0aGVyX2FkZHJfY29weShlbGVtZW50Lm1hY19hZGRy
LCBtYWNhZGRyKTsNCj4gPiArICAgICAgIGVsZW1lbnQuZmxhZ3MgPSBjcHVfdG9fbGUxNihJNDBF
X0FRQ19NQUNWTEFOX0FERF9QRVJGRUNUX01BVENIKTsNCj4gPiArICAgICAgIHJldCA9IGk0MGVf
YXFfYWRkX21hY3ZsYW4oJnZzaS0+YmFjay0+aHcsIHZzaS0+c2VpZCwgJmVsZW1lbnQsDQo+IDEs
IE5VTEwpOw0KPiA+ICsgICAgICAgYXFfZXJyID0gdnNpLT5iYWNrLT5ody5hcS5hc3FfbGFzdF9z
dGF0dXM7DQo+IA0KPiBEbyB5b3UgcmVhbGx5IG5lZWQgYSBzZXBhcmF0ZSB2YXJpYWJsZSAoYXFf
ZXJyKT8NCg0KVGhlc2UgYXJlIHR3byBzZXBhcmF0ZSBlcnJvciB2YWx1ZXMgdGhhdCB3ZSdyZSB0
cmFja2luZyAtIG9uZSBmcm9tIHRoZSBjb21tdW5pY2F0aW9uIGJldHdlZW4gdGhlIGRyaXZlciBh
bmQgdGhlIGZpcm13YXJlIChhcV9lcnIpIGFuZCBvbmUgZnJvbSB0aGUgZHJpdmVyIGFjdGl2aXR5
LiAgU29tZXRpbWVzIHRoZXJlIG1heSBiZSBhbiBBUSBlcnJvciB0aGF0IHdlIHdhbnQgdG8gcmVw
b3J0LCBidXQgaXQgbWlnaHQgbm90IGFjdHVhbGx5IGJlIGEgZHJpdmVyIGVycm9yLiAgQWx0ZXJu
YXRpdmVseSwgdGhlcmUgYXJlIHRpbWVzIHdoZW4gdGhlIEFRIGVycm9yIG5lZWRzIHRvIGdldCBp
bnRlcnByZXRlZCBkaWZmZXJlbnQgd2F5cyBkZXBlbmRpbmcgb24gd2hpY2ggdGFzayB0aGUgZHJp
dmVyIGlzIHBlcmZvcm1pbmcuICBMYXN0bHksIHRoZSBBUSBlcnJvciBnaXZlcyB1cyBtb3JlIGRl
dGFpbCBvbiB3aGF0ZXZlciB0aGUgdHJhbnNhY3Rpb24gZXJyb3IgbWF5IGhhdmUgYmVlbiB3aGlj
aCBnaXZlcyB1cyBtb3JlIHVzZWZ1bCBkZWJ1ZyBpbmZvLg0KDQpzbG4NCg==
