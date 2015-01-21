From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [E1000-devel] [PATCH 1/2] if_link: Add VF multicast promiscuous
	mode control
Date: Wed, 21 Jan 2015 11:56:53 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAD01D6@AcuExch.aculab.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E0734E@BPXM14GP.gisp.nec.co.jp>
	<874mrlu18e.fsf@nemi.mork.no>
 <7F861DC0615E0C47A872E6F3C5FCDDBD05E07B7C@BPXM14GP.gisp.nec.co.jp>
 <F6FB0E698C9B3143BDF729DF222866469129B7F5@ORSMSX110.amr.corp.intel.com>
 <7F861DC0615E0C47A872E6F3C5FCDDBD05E07F09@BPXM14GP.gisp.nec.co.jp>
 <F6FB0E698C9B3143BDF729DF222866469129B844@ORSMSX110.amr.corp.intel.com>
 <7F861DC0615E0C47A872E6F3C5FCDDBD05E08FF6@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Hayato Momma <h-momma@ce.jp.nec.com>
To: 'Hiroshi Shimamoto' <h-shimamoto@ct.jp.nec.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	=?utf-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.188]:53700 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbbAUL5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 06:57:49 -0500
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E08FF6@BPXM14GP.gisp.nec.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSGlyb3NoaSBTaGltYW1vdG8NCj4gTXkgY29uY2VybiBpcyB3aGF0IGlzIHRoZSByZWFs
IGlzc3VlIHRoYXQgVkYgbXVsdGljYXN0IHByb21pc2N1b3VzIG1vZGUgY2FuIGNhdXNlLg0KPiBJ
IHRoaW5rIHRoZXJlIGlzIHRoZSA0ayBlbnRyaWVzIHRvIGZpbHRlciBtdWx0aWNhc3QgYWRkcmVz
cywgYW5kIHRoZSBjdXJyZW50IGl4Z2JlL2l4Z2JldmYNCj4gY2FuIHR1cm4gYWxsIGJpdHMgb24g
ZnJvbSBWTS4gVGhhdCBpcyBhbG1vc3Qgc2FtZSBhcyBlbmFibGluZyBtdWx0aWNhc3QgcHJvbWlz
Y3VvdXMgbW9kZS4NCj4gSSBtZWFuIHRoYXQgd2UgY2FuIHJlY2VpdmUgYWxsIG11bHRpY2FzdCBh
ZGRyZXNzZXMgYnkgYW4gb25lcm91cyBvcGVyYXRpb24gaW4gdW50cnVzdGVkIFZNLg0KPiBJIHRo
aW5rIHdlIHNob3VsZCBjbGFyaWZ5IHdoYXQgaXMgcmVhbCBzZWN1cml0eSBpc3N1ZSBpbiB0aGlz
IGNvbnRleHQuDQoNCklmIHlvdSBhcmUgd29ycmllZCBhYm91dCBwYXNzaW5nIHVuLWVuYWJsZWQg
bXVsdGljYXN0cyB0byB1c2VycyB0aGVuDQp3aGF0IGFib3V0IGRvaW5nIGEgc29mdHdhcmUgaGFz
aCBvZiByZWNlaXZlZCBtdWx0aWNhc3RzIGFuZCBjaGVja2luZw0KYWdhaW5zdCBhbiBhY3R1YWwg
bGlzdCBvZiBtdWx0aWNhc3RzIGVuYWJsZWQgZm9yIHRoYXQgaGFzaCBlbnRyeS4NClVuZGVyIG5v
cm1hbCBjb25kaXRpb25zIHRoZXJlIGlzIGxpa2VseSB0byBiZSBvbmx5IGEgc2luZ2xlIGFkZHJl
c3MgdG8gY2hlY2suDQoNCkl0IG1heSAob3IgbWF5IG5vdCkgYmUgYmVzdCB0byB1c2UgdGhlIHNh
bWUgaGFzaCBhcyBhbnkgaGFzaGluZyBoYXJkd2FyZQ0KZmlsdGVyIHVzZXMuDQoNCglEYXZpZA0K
DQo=
