From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH ethtool] ethtool.c: fix memory leaks
Date: Mon, 27 Jun 2016 09:59:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4E502E@AcuExch.aculab.com>
References: <1458303855-4976-1-git-send-email-ivecera@redhat.com>
 <1466931551.2504.29.camel@decadent.org.uk>
 <9365ac33-5c0d-9afe-bf2a-e83790f11b74@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "bwh@kernel.org" <bwh@kernel.org>
To: 'Ivan Vecera' <ivecera@redhat.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:56126 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbcF0KB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 06:01:27 -0400
In-Reply-To: <9365ac33-5c0d-9afe-bf2a-e83790f11b74@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSXZhbiBWZWNlcmENCj4gU2VudDogMjcgSnVuZSAyMDE2IDEwOjQxDQo+IE9uIDI2LjYu
MjAxNiAxMDo1OSwgQmVuIEh1dGNoaW5ncyB3cm90ZToNCj4gPiBPbiBGcmksIDIwMTYtMDMtMTgg
YXQgMTM6MjQgKzAxMDAsIEl2YW4gVmVjZXJhIHdyb3RlOg0KPiA+PiBNZW1vcnkgYWxsb2NhdGVk
IGF0IHNldmVyYWwgcGxhY2VzIGlzIG5vdCBhcHByb3ByaWF0ZWx5IGZyZWVkLg0KPiA+DQo+ID4g
R2l2ZW4gdGhhdCBldGh0b29sIGlzIG5vdCBhIGxpYnJhcnkgb3IgYSBsb25nLXJ1bm5pbmcgYXBw
bGljYXRpb24gLSB3aHkNCj4gPiBkb2VzIHRoYXQgbWF0dGVyPw0KPiA+DQo+ID4gQmVuLg0KPiAN
Cj4gQmVjYXVzZSBlYWNoIGRlY2VudGx5IHdyaXR0ZW4gcHJvZ3JhbSBzaG91bGQgY2xlYW4gdXAu
IFN1cmUgdGhlIGtlcm5lbA0KPiB3aWxsIHRha2UgY2FyZSBhYm91dCBpdCBhZnRlciBleGl0IGJ1
dCB3ZSBjYW5ub3QgYWNjZXB0IHRoZSBmYWN0IHRoYXQNCj4gc2hvcnQtcnVubmluZyBhcHBsaWNh
dGlvbnMgY2FuIGJlaGF2ZSBsaWtlIGEgcGlnLg0KDQpJdCByZWFsbHkgZG9lc24ndCBtYXR0ZXIg
ZXhjZXB0IGZvciBtZW1vcnkgdGhhdCBtaWdodCBiZSBhbGxvY2F0ZWQNCnJlcGVhdGVkbHkuDQpU
aGUgcmlza3Mgb2YgZ2V0dGluZyBpdCB3cm9uZyBwcm9iYWJseSBvdXR3YXkgYW55IG1pbm9yIGJl
bmVmaXQuDQoNCmZyZWUoKSBpcyBhbHNvIHVubGlrZWx5IHRvIHJlZHVjZSB0aGUgcHJvZ3JhbSBz
aXplICh0byBkbyBzbyB3b3VsZCByZXF1aXJlDQphIHN5c3RlbSBjYWxsIGFuZCBUTEIgZmx1c2gg
b24gdG9wIG9mIGV2ZXJ5dGhpbmcgZWxzZSkuDQoNCglEYXZpZA0K
