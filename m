From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: can: usb: peak_usb: pcan_usb_core.c: Cleaning up
 missing null-terminate in conjunction with strncpy
Date: Tue, 16 Sep 2014 08:40:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17493206@AcuExch.aculab.com>
References: <1410715898-15904-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
 <063D6719AE5E284EB5DD2968C1650D6D17491F2B@AcuExch.aculab.com>
 <5416A65D.6010500@pengutronix.de>
 <063D6719AE5E284EB5DD2968C1650D6D17491F83@AcuExch.aculab.com>
 <CAFo99gb9Rqnc7HrPbN7UVyQwPv_a=fxAbe+FTtm+9GgsjG7StA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Stephane Grosjean" <s.grosjean@peak-system.com>,
	Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"Christopher R. Baker" <cbaker@rec.ri.cmu.edu>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Rickard Strandqvist' <rickard_strandqvist@spectrumdigital.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFo99gb9Rqnc7HrPbN7UVyQwPv_a=fxAbe+FTtm+9GgsjG7StA@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogUmlja2FyZCBTdHJhbmRxdmlzdCANCj4gPiAyMDE0LTA5LTE1IDEwOjQ3IEdNVCswMjow
MCBEYXZpZCBMYWlnaHQgPERhdmlkLkxhaWdodEBhY3VsYWIuY29tPjoNCi4uLg0KPiA+IE9yOg0K
PiA+ICAgICBjaGFyIG5hbWVbc2l6ZW9mIG5ldGRldi0+bmFtZV07DQo+ID4gICAgIG1lbWNweShu
YW1lLCBuZXRkZXYtPm5hbWUsIHNpemVvZiBuZXRkZXYtPm5hbWUpOw0KPiA+DQouLi4NCj4gSSBs
aWtlZCB0aGUgdmFyaWFudDoNCj4gY2hhciBuYW1lW3NpemVvZihuZXRkZXYtPm5hbWUpXTsNCj4g
DQo+IEJ1dCBkaXNsaWtlIGFuZCBkbyBub3QgdW5kZXJzdGFuZCB3aGF0IHRoZSBwb2ludCB3b3Vs
ZCBiZSB3aXRoIG1lbWNweSB2YXJpYW50Lg0KDQpUaGUgbWVtY3B5KCkgd2lsbCBiZSBhIGxvdCBm
YXN0ZXIgdGhhbiBhbnkgb2YgdGhlIHN0cmluZyBjb3B5IGZ1bmN0aW9ucw0KYmVjYXVzZSBpdCBk
b2Vzbid0IG5lZWQgdG8gd29ycnkgYWJvdXQgdGhlIHRlcm1pbmF0b3IuDQpJbiBtYW55IGNhc2Vz
IGl0IHdpbGwgYmUgaW5saW5lZCB0byBhIHNob3J0IHNlcmllcyBvZiBsb2FkIGFuZCBzdG9yZXMu
DQoNCglEYXZpZA0KDQo=
