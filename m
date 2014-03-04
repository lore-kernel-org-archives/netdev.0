From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 08/12] r8152: support TSO
Date: Tue, 4 Mar 2014 15:14:01 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6D0334@AcuExch.aculab.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
	 <1393934464-23675-9-git-send-email-hayeswang@realtek.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6CFFE0@AcuExch.aculab.com>
	 <CF9EF717568D49DB858D5363B1099FC0@realtek.com.tw>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6D0284@AcuExch.aculab.com>
 <1393945351.26794.110.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: 'hayeswang' <hayeswang@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nic_swsd@realtek.com" <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393945351.26794.110.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogRXJpYyBEdW1hemV0IA0KPiBPbiBUdWUsIDIwMTQtMDMtMDQgYXQgMTQ6MzUgKzAwMDAs
IERhdmlkIExhaWdodCB3cm90ZToNCj4gDQo+ID4gRG9lcyB0aGF0IG1lYW4geW91IGFyZSBzcGxp
dHRpbmcgdGhlIDY0ayAnZXRoZXJuZXQgcGFja2V0JyBmcm9tIFRDUA0KPiA+IGlzIHNvZnR3YXJl
PyBJJ3ZlIGxvb2tlZCBhdCB0aGUgYXg4ODE3OSB3aGVyZSB0aGUgaGFyZHdhcmUgY2FuIGRvIGl0
Lg0KPiA+DQo+ID4gSXMgdGhlcmUgcmVhbGx5IGEgZ2FpbiBkb2luZyBzZWdtZW50YXRpb24gaGVy
ZSBpZiB5b3UgaGF2ZSB0byBkbyB0aGUNCj4gPiBleHRyYSBkYXRhIGNvcHk/DQo+IA0KPiBUaGVy
ZSBpcyBubyAnZXh0cmEnIGNvcHkuDQo+IA0KPiBUaGVyZSBpcyBfYWxyZWFkeV8gYSBjb3B5LCBz
byB3aGF0J3MgdGhlIGRlYWwgb2YgZG9pbmcgdGhpcyBjb3B5IGluIGEgU0cNCj4gZW5hYmxlZCB3
YXkgPw0KDQpPay4NCg0KQnV0IHRoZXJlIGlzIG9uZSBtb3JlIGNvcHkgdGhhbiBmb3IgYSBub3Jt
YWwgZXRoZXJuZXQgY2hpcHNldCB3aGljaA0KY2FuIHVzZSBtdWx0aXBsZSByaW5nIGVudHJpZXMg
dG8gc2VuZCB0aGUgTUFDK0lQK1RDUCBoZWFkZXJzIGZyb20gYQ0KZGlmZmVyZW50IGJ1ZmZlciB0
byB0aGUgVENQIHVzZXJkYXRhLg0KDQoJRGF2aWQNCg0K
