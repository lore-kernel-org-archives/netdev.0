From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH v3 2/4] net: Allow for more then a single subclass for
 netif_addr_lock
Date: Wed, 4 Jun 2014 22:50:22 +0000
Message-ID: <1401922221.4508.0.camel@jekeller-desk1.amr.corp.intel.com>
References: <1400274296-14765-1-git-send-email-vyasevic@redhat.com>
	 <1400274296-14765-3-git-send-email-vyasevic@redhat.com>
	 <1401918131.24086.9.camel@jekeller-desk1.amr.corp.intel.com>
	 <20140604.145344.1776321352568977848.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"vfalico@gmail.com" <vfalico@gmail.com>,
	"dingtianhong@huawei.com" <dingtianhong@huawei.com>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"kaber@trash.net" <kaber@trash.net>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15723 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122AbaFDWur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 18:50:47 -0400
In-Reply-To: <20140604.145344.1776321352568977848.davem@davemloft.net>
Content-Language: en-US
Content-ID: <25E1FE691CDF7345A2F9A7356CE4B0B7@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gV2VkLCAyMDE0LTA2LTA0IGF0IDE0OjUzIC0wNzAwLCBEYXZpZCBNaWxsZXIgd3JvdGU6DQo+
IEZyb206ICJLZWxsZXIsIEphY29iIEUiIDxqYWNvYi5lLmtlbGxlckBpbnRlbC5jb20+DQo+IERh
dGU6IFdlZCwgNCBKdW4gMjAxNCAyMTo0MjoxMiArMDAwMA0KPiANCj4gPiBUaGlzIG9ubHkgb2Nj
dXJzIGlmIENPTkZJR19ERUJVR19MT0NLX0FMTE9DPVksIGFuZCB0aGVyZSBzZWVtcyB0byBiZSBu
bw0KPiA+IGVhc3kgZml4IGZvciB0aGUgd2FybmluZywgZHVlIHRvIGhvdyBzcGluX2xvY2tfbmVz
dGVkIGlzIGEgbWFjcm8gdGhhdA0KPiA+IGRpc2NhcmRzIHRoZSBzZWNvbmQgcGFyYW1ldGVyIHdo
ZW4gREVCVUdfTE9DS19BTExPQyBpcyBkaXNhYmxlZC4NCj4gDQo+IHNwaW5fbG9ja19uZXN0ZWQo
KSwgaW4gdGhhdCBjYXNlLCBzaG91bGQgbWFyayB0aGUgYXJndW1lbnQgYXMgdW51c2VkLg0KPiAN
Cj4gLS0NCj4gVG8gdW5zdWJzY3JpYmUgZnJvbSB0aGlzIGxpc3Q6IHNlbmQgdGhlIGxpbmUgInVu
c3Vic2NyaWJlIG5ldGRldiIgaW4NCj4gdGhlIGJvZHkgb2YgYSBtZXNzYWdlIHRvIG1ham9yZG9t
b0B2Z2VyLmtlcm5lbC5vcmcNCj4gTW9yZSBtYWpvcmRvbW8gaW5mbyBhdCAgaHR0cDovL3ZnZXIu
a2VybmVsLm9yZy9tYWpvcmRvbW8taW5mby5odG1sDQoNCkNhbiBpdCBkbyB0aGF0PyBzcGluX2xv
Y2tfbmVzdGVkIGlzIGEgbWFjcm8uDQoNClRoYW5rcywNCkpha2UNCg==
