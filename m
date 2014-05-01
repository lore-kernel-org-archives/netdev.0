From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: via-rhine: Fix compiler warning re: pointer
 casting on 64bit
Date: Thu, 1 May 2014 09:30:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F703980@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F702D00@AcuExch.aculab.com>
 <1398859589-22346-1-git-send-email-alchark@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: 'Alexey Charkov' <alchark@gmail.com>,
	Roger Luethi <rl@hellgate.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Jan Moskyto Matejka" <mq@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398859589-22346-1-git-send-email-alchark@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogQWxleGV5IENoYXJrb3YgW21haWx0bzphbGNoYXJrQGdtYWlsLmNvbV0NCi4uLg0KPiBU
aGlzIHBhdGNoIHJlbW92ZXMgdGhlIGNhc3QgYWx0b2dldGhlciwgYW5kIGluc3RlYWQgc3RvcmVz
IGFuIGFjdHVhbA0KPiBwb2ludGVyIHRvIHU4IGluIG1hdGNoLT5kYXRhLiBBbGwgaW5zdGFuY2Vz
IG9mICdyZXZpc2lvbicgYXJlIGFsc28NCj4gdW5pZmllZCB0byB1OCBpbnN0ZWFkIG9mIGFuIGFz
c29ydG1lbnQgb2YgZGlmZmVyZW50IGludGVnZXIgdHlwZXMsDQo+IGluIGxpbmUgd2l0aCB0aGUg
ZGVmaW5pdGlvbiBvZiAncmV2aXNpb24nIGluIHN0cnVjdCBwY2lfZGV2Lg0KLi4uDQo+ICtzdGF0
aWMgdTggdnQ4NTAwX3JldmlzaW9uID0gMHg4NDsNCj4gIHN0YXRpYyBzdHJ1Y3Qgb2ZfZGV2aWNl
X2lkIHJoaW5lX29mX3RibFtdID0gew0KPiAtCXsgLmNvbXBhdGlibGUgPSAidmlhLHZ0ODUwMC1y
aGluZSIsIC5kYXRhID0gKHZvaWQgKikweDg0IH0sDQo+ICsJeyAuY29tcGF0aWJsZSA9ICJ2aWEs
dnQ4NTAwLXJoaW5lIiwgLmRhdGEgPSAmdnQ4NTAwX3JldmlzaW9uIH0sDQo+ICAJeyB9CS8qIHRl
cm1pbmF0ZSBsaXN0ICovDQoNCkFjdHVhbGx5IHRoZSBhYm92ZSBsb29rcyBzdHJhbmdlLg0KV2h5
IGRvZXMgdGhlIHZ0ODUwMCBoYXZlIGEgcmV2aXNpb24gbnVtYmVyIG9mIDB4ODQgPw0KU3VyZWx5
IGl0IHNob3VsZCBiZSAweDg1LCBvciBldmVuIDB4ODUwMCAob3IgZGVjaW1hbCA4NTAwMCkuDQoN
CglEYXZpZA0KDQo=
