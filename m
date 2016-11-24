From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 24 Nov 2016 12:37:23 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201055E28@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-227-Taiwan-albertk@realtek.com>
 <0835B3720019904CB8F7AA43166CEEB20105013E@RTITMBSV03.realtek.com.tw>
 <d683c019-4e0f-6fe6-368c-c4fc86c72fe6@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201050B7E@RTITMBSV03.realtek.com.tw>
 <b9809516-d036-bfc3-b7a3-6563033ec957@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB2010517CE@RTITMBSV03.realtek.com.tw>
 <b61a0e10-c737-8912-3e4e-393f4eb32077@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Mark Lord <mlord@pobox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b61a0e10-c737-8912-3e4e-393f4eb32077@pobox.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TWFyayBMb3JkIFttYWlsdG86bWxvcmRAcG9ib3guY29tXQ0KPiBTZW50OiBXZWRuZXNkYXksIE5v
dmVtYmVyIDIzLCAyMDE2IDk6NDEgUE0NClsuLi5dIA0KPiA+c3RhdGljIHZvaWQgcjgxNTNfc2V0
X3J4X2Vhcmx5X3NpemUoc3RydWN0IHI4MTUyICp0cCkNCj4gPnsNCj4gPiAgICAgICAgdTMyIG10
dSA9IHRwLT5uZXRkZXYtPm10dTsNCj4gPiAgICAgICAgdTMyIG9jcF9kYXRhID0gKGFnZ19idWZf
c3ogLSBtdHUgLSBWTEFOX0VUSF9ITEVOIC0gVkxBTl9ITEVOKSAvIDQ7DQo+ID4NCj4gPiAgICAg
ICAgb2NwX3dyaXRlX3dvcmQodHAsIE1DVV9UWVBFX1VTQiwgVVNCX1JYX0VBUkxZX1NJWkUsIG9j
cF9kYXRhKTsNCj4gPn0NCj4gDQo+IEhvdyBpcyBvY3BfZGF0YSB1c2VkIGJ5IHRoZSBoYXJkd2Fy
ZT8NCj4gU2hvdWxkbid0IHRoZSBjYWxjdWxhdGlvbiBhbHNvIGluY2x1ZGUgc2l6ZW9mKHJ4X2Rl
c2MpIGluIHRoZXJlIHNvbWV3aGVyZT8NCg0KSSBjaGVjayB5b3VyIHF1ZXN0aW9uIHdpdGggb3Vy
IGh3IGVuZ2luZWVycywgYW5kIHlvdSBhcmUgcmlnaHQuDQpUaGUgc2l6ZSBvZiByeCBkZXNjcmlw
dG9yIHNob3VsZCBiZSBjYWxjdWxhdGVkLCB0b28uDQoNCkJlc3QgUmVnYXJkcywNCkhheWVzDQoN
Cg0K
