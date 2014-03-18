From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] net: netfilter: LLVMLinux: vlais-netfilter
Date: Tue, 18 Mar 2014 15:24:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6E0286@AcuExch.aculab.com>
References: <022D9517-4804-47BB-B789-CCF25F25C1ED@me.com>
 <1395123121-27053-1-git-send-email-behanw@converseincode.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6E0065@AcuExch.aculab.com>
 <53285C79.2060907@converseincode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "pablo@netfilter.org" <pablo@netfilter.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"kadlec@blackhole.kfki.hu" <kadlec@blackhole.kfki.hu>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netfilter@vger.kernel.org" <netfilter@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dwmw2@infradead.org" <dwmw2@infradead.org>,
	"pageexec@freemail.hu" <pageexec@freemail.hu>,
	Mark Charlebois <charlebm@gmail.com>,
	=?utf-8?B?Vmluw61jaXVzIFRpbnRp?= <viniciustinti@gmail.com>
To: 'Behan Webster' <behanw@converseincode.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33742 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755674AbaCRPZb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 11:25:31 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16206-05 for <netdev@vger.kernel.org>;
 Tue, 18 Mar 2014 15:25:28 +0000 (GMT)
In-Reply-To: <53285C79.2060907@converseincode.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQmVoYW4gV2Vic3RlciANCj4gT24gMDMvMTgvMTQgMDI6NDEsIERhdmlkIExhaWdodCB3
cm90ZToNCj4gPiBGcm9tOiAgYmVoYW53QGNvbnZlcnNlaW5jb2RlLmNvbQ0KPiA+PiBGcm9tOiBN
YXJrIENoYXJsZWJvaXMgPGNoYXJsZWJtQGdtYWlsLmNvbT4NCj4gPj4NCj4gPj4gUmVwbGFjZWQg
bm9uLXN0YW5kYXJkIEMgdXNlIG9mIFZhcmlhYmxlIExlbmd0aCBBcnJheXMgSW4gU3RydWN0cyAo
VkxBSVMpIGluDQo+ID4+IHh0X3JlcGxkYXRhLmggd2l0aCBhIEM5OSBjb21wbGlhbnQgZmxleGli
bGUgYXJyYXkgbWVtYmVyIGFuZCB0aGVuIGNhbGN1bGF0ZWQNCj4gPj4gb2Zmc2V0cyB0byB0aGUg
b3RoZXIgc3RydWN0IG1lbWJlcnMuIFRoZXNlIG90aGVyIG1lbWJlcnMgYXJlbid0IHJlZmVyZW5j
ZWQgYnkNCj4gPj4gbmFtZSBpbiB0aGlzIGNvZGUsIGhvd2V2ZXIgdGhpcyBwYXRjaCBtYWludGFp
bnMgdGhlIHNhbWUgbWVtb3J5IGxheW91dCBhbmQNCj4gPj4gcGFkZGluZyBhcyB3YXMgcHJldmlv
dXNseSBhY2NvbXBsaXNoZWQgdXNpbmcgVkxBSVMuDQo+ID4+DQo+ID4+IEhhZCB0aGUgb3JpZ2lu
YWwgc3RydWN0dXJlIGJlZW4gb3JkZXJlZCBkaWZmZXJlbnRseSwgd2l0aCB0aGUgZW50cmllcyBW
TEEgYXQNCj4gPj4gdGhlIGVuZCwgdGhlbiBpdCBjb3VsZCBoYXZlIGJlZW4gYSBmbGV4aWJsZSBt
ZW1iZXIsIGFuZCB0aGlzIHBhdGNoIHdvdWxkIGhhdmUNCj4gPj4gYmVlbiBhIGxvdCBzaW1wbGVy
LiBIb3dldmVyIHNpbmNlIHRoZSBkYXRhIHN0b3JlZCBpbiB0aGlzIHN0cnVjdHVyZSBpcw0KPiA+
PiB1bHRpbWF0ZWx5IGV4cG9ydGVkIHRvIHVzZXJzcGFjZSwgdGhlIG9yZGVyIG9mIHRoaXMgc3Ry
dWN0dXJlIGNhbid0IGJlIGNoYW5nZWQuDQo+ID4gV2h5IG5vdCBqdXN0IHJlbW92ZSB0aGUgbGFz
dCBlbGVtZW50IGFuZCBhbGxvY2F0ZSBzcGFjZSBmb3IgaXQgYWZ0ZXIgdGhlDQo+ID4gc3RydWN0
dXJlPw0KPiBCZWNhdXNlIHRoYXQgd291bGQgc3RpbGwgYmUgZW1wbG95aW5nIFZMQUlTIHRvIHNv
bHZlIHRoZSBwcm9ibGVtLiBUaGUNCj4gbGFzdCBlbGVtZW50IG1heSBiZSBhIHplcm8tbGVuZ3Ro
IGFycmF5IChhIGZsZXhpYmxlIG1lbWJlciksIG5vdCBhIFZMQS4NCj4gU2FkbHkgYm90aCB0aGUg
bGFzdCAyIGVsZW1lbnRzIGluIHRoZSBzdHJ1Y3QgbmVlZCB0byBiZSBtYW51YWxseQ0KPiBjYWxj
dWxhdGVkLCB3aGljaCBpcyB3aGF0IHdlJ3ZlIGRvbmUuDQoNClNvIG1ha2UgdGhlIGxhc3QgZWxl
bWVudCBhICdmbGV4aWJsZSBtZW1iZXInIGFuZCB0aGVuIHdvcmsgb3V0IHdoZXJlDQp0aGUgZmlu
YWwgZmllbGQgZ29lcy4NClNvbWV0aGluZyBsaWtlOg0KCXN0cnVjdCBwIHsNCgkJc3RydWN0IGEg
YTsNCgkJc3RydWN0IGIgYltdOw0KCX0gcCA9IG1hbGxvYyhzaXplb2YgKnAgKyBuICogc2l6ZW9m
IChzdHJ1Y3QgYikgKyBhbGlnbm9mIChzdHJ1Y3QgYykNCgkJKyBzaXplb2YgKHN0cnVjdCBjKTsN
CglzdHJ1Y3QgYyAqYyA9ICh2b2lkICopJnAtPmJbbl0gKyAoLW9mZnNldG9mKHN0cnVjdCBwLCBi
W25dKSAmIChhbGlnbm9mKHN0cnVjdCBjKSAtIDEpOw0KDQoJRGF2aWQNCg0KDQo=
