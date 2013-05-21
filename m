From: Bing Zhao <bzhao@marvell.com>
Subject: RE: [RFC PATCH] net/wireless/mwifiex/pcie: Convert to dev_pm_ops
 from legacy pm ops
Date: Tue, 21 May 2013 11:49:33 -0700
Message-ID: <477F20668A386D41ADCC57781B1F70430E0ADCE838@SC-VEXCH1.marvell.com>
References: <1369103589.12093.4.camel@lorien>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shuahkhan@gmail.com" <shuahkhan@gmail.com>
To: Shuah Khan <shuah.kh@samsung.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"rafael.j.wysocki@intel.com" <rafael.j.wysocki@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369103589.12093.4.camel@lorien>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SGkgU2h1YWgsDQoNCj4gQ29udmVydCB0aGUgZHJpdmVyIHRvIHVzZSBkZXZfcG1fb3BzIGZvciBw
b3dlciBtYW5hZ2VtZW50IGFuZCByZW1vdmUgTGVnYWN5IFBNDQo+IGhhbmRsaW5nLiBUaGlzIGNo
YW5nZSByZS11c2VzIGV4aXN0aW5nIHN1c3BlbmQgYW5kIHJlc3VtZSBpbnRlcmZhY2VzIGZvcg0K
PiBkZXZfcG1fb3BzLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogU2h1YWggS2hhbiA8c2h1YWgua2hA
c2Ftc3VuZy5jb20+DQo+IENjOiBTaHVhaCBLaGFuIDxzaHVhaGtoYW5AZ21haWwuY29tPg0KPiBT
dWdnZXN0ZWQtYnk6IHJhZmFlbC5qLnd5c29ja2lAaW50ZWwuY29tDQoNCkFja2VkLWJ5OiBCaW5n
IFpoYW8gPGJ6aGFvQG1hcnZlbGwuY29tPg0KDQpUaGFua3MsDQpCaW5nDQoNCj4gLS0tDQo+IA0K
PiBSYWZhZWwsDQo+IA0KPiBUaGlzIGlzIHRoZSBmaXJzdCBkcml2ZXIgcGF0Y2ggdG8gY29udmVy
dCBkcml2ZXJzIHRvIHVzZSBkZXZfcG1fb3BzIGZvcg0KPiBwb3dlciBtYW5hZ2VtZW50LiBQbGVh
c2UgcmV2aWV3IGZvciB0aGUgYXBwcm9hY2ggYW5kIG1ha2Ugc3VnZ2VzdGlvbnMgZm9yDQo+IGlt
cHJvdmVtZW50Lg0KPiANCj4gdGhhbmtzLA0KPiAtLSBTaHVhaA0K
