From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: Re: [RFC 00/11] QLogic RDMA Driver (qedr) RFC
Date: Mon, 12 Sep 2016 17:39:35 +0000
Message-ID: <CY4PR11MB17202A542AC07CBA4A65E93697FF0@CY4PR11MB1720.namprd11.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <20160912163928.GK8812@leon.nu>,<CAG53R5UqF21z34jB2HJCTXU8w3Kbj_Jon=wBAoO5tYSqbD1f6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Ram Amrani <Ram.Amrani@qlogic.com>,
        Doug Ledford <dledford@redhat.com>,
        David Miller <davem@davemloft.net>,
        Ariel Elior <Ariel.Elior@qlogic.com>,
        Michal Kalderon <Michal.Kalderon@qlogic.com>,
        Rajesh Borundia <rajesh.borundia@qlogic.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Parav Pandit <pandit.parav@gmail.com>,
        Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0098.outbound.protection.outlook.com ([104.47.37.98]:35920
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757283AbcILRji (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 13:39:38 -0400
In-Reply-To: <CAG53R5UqF21z34jB2HJCTXU8w3Kbj_Jon=wBAoO5tYSqbD1f6g@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pj4+wqAgaW5jbHVkZS9saW51eC9xZWQvY29tbW9uX2hzaS5owqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqAgfMKgwqDCoCAxICsNCj4+PsKgIGluY2x1ZGUvbGludXgvcWVkL3FlZF9pZi5o
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoCB8wqDCoMKgIDkgKy0NCj4+
PsKgIGluY2x1ZGUvbGludXgvcWVkL3FlZF9sbDJfaWYuaMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgIHzCoCAxNDAgKw0KPj4+wqAgaW5jbHVkZS9saW51eC9xZWQvcWVkX3JvY2VfaWYu
aMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoCB8wqAgNjA0ICsrKysNCj4+PsKgIGluY2x1
ZGUvbGludXgvcWVkL3FlZGVfcm9jZS5owqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oCB8wqDCoCA4OCArDQo+PsKgPiBpbmNsdWRlL2xpbnV4L3FlZC9yZG1hX2NvbW1vbi5owqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgIHzCoMKgwqAgMSArDQo+Pg0KPj4gU29tZXRoaW5nIG5v
dCBkaXJlY3RseSByZWxhdGVkIHRvIHlvdXIgcGF0Y2hlcywgYnV0IHRoZXkgYnJvdWdodCBteQ0K
Pj4gYXR0ZW50aW9uIHRvIHRoZSBmYWN0IHRoYXQgYWxsIHRoZXNlIG5ldyAoYW5kIG9sZCkgcmRt
YTwtPm5ldCBkZXZpY2VzDQo+PiBhcmUgcG9sbHV0aW5nIGluY2x1ZGUvbGludXgNCj4+DQo+IG9j
cmRtYSBkcml2ZXIgaW5jbHVkZXMgYmVfcm9jZS5oIGxvY2F0ZWQgaW4gbmV0L2V0aGVybmV0L2Vt
dWxleC9iZW5ldA0KPiBsb2NhdGlvbiBpbnN0ZWFkIG9mIGluY2x1ZGUvbGludXgvLg0KPiBUaGlz
IGZpbGUgaGVscHMgdG8gYmluZCByZG1hIHRvIG5ldCBkZXZpY2Ugb3IgdW5kZXJseWluZyBodyBk
ZXZpY2UuDQoNCj4gTWF5IGJlIHNpbWlsYXIgY2hhbmdlIGNhbiBiZSBkb25lIGZvciByZXN0IG9m
IHRoZSBkcml2ZXJzIGZvcg0KPiByZG1hPC0tPm5ldCBkZXZpY2VzPw0KDQpCeSBhZGRpbmcgZXhw
bGljaXQgaW5jbHVzaW9uIHBhdGhzIGluIHRoZSBNYWtlZmlsZSwgYSBsYQ0KY2NmbGFncy15IDo9
IC1JZHJpdmVycy9uZXQvZXRoZXJuZXQvZW11bGV4L2JlbmV0ICAgPw0KDQpXaGlsZSB0aGlzIG1p
Z2h0IHdvcmssIEkgcGVyc29uYWxseSBkaXNsaWtlIGl0IGFzIEkgZmluZCBpdA0KY291bnRlci1p
bnR1aXRpdmUgd2hlbiBnb2luZyBvdmVyIHRoZSBjb2RlIC0NCkkgZG9uJ3QgZXhwZWN0IGRyaXZl
ciB0byBsb2NhbGx5IG1vZGlmeSB0aGUgaW5jbHVzaW9uIHBhdGguDQpCZXNpZGVzLCB3ZSdyZSBn
b2luZyB0byBbZXZlbnR1YWxseV0gYSB3aG9sZSBzdWl0ZSBvZiBkcml2ZXJzIGJhc2VkDQpvbiB0
aGUgcWVkIG1vZHVsZSwgc29tZSBvZiB3aGljaCB3b3VsZCByZXNpZGUgdW5kZXIgZHJpdmVycy9z
Y3NpOw0KTm90IHN1cmUgaXQncyBiZXN0IHRvIGhhdmUgMyBvciA0IGRpZmZlcmVudCBkcml2ZXJz
IHByaXZhdGVseSBpbmNsdWRlIHRoZQ0Kc2FtZSBkaXJlY3RvcnkgdW5kZXIgYSBkaWZmZXJlbnQg
c3Vic3lzdGVtLg0KDQo+PiBGaWx0ZXJlZCBvdXRwdXQ6DQo+PiDinpzCoCBsaW51eC1yZG1hIGdp
dDoodG9waWMvZml4ZXMtZm9yLTQuOC0yKSBscyAtZGwgaW5jbHVkZS9saW51eC8qLw0KPj4gZHJ3
eHJ3eHIteMKgIDIgbGVvbnJvIGxlb25yb8KgIDQwOTYgQXVnIDMwIDE2OjI3IGluY2x1ZGUvbGlu
dXgvaHNpLw0KPj4gZHJ3eHJ3eHIteMKgIDIgbGVvbnJvIGxlb25yb8KgIDQwOTYgU2VwIDEyIDE5
OjA4IGluY2x1ZGUvbGludXgvbWx4NC8NCj4+IGRyd3hyd3hyLXjCoCAyIGxlb25ybyBsZW9ucm/C
oCA0MDk2IFNlcMKgIDcgMTU6MzEgaW5jbHVkZS9saW51eC9tbHg1Lw0KPj4gZHJ3eHJ3eHIteMKg
IDIgbGVvbnJvIGxlb25yb8KgIDQwOTYgU2VwwqAgOCAxNzo0NiBpbmNsdWRlL2xpbnV4L3FlZC8N
Cj4+DQo+PiBJcyB0aGlzIHRoZSByaWdodCBwbGFjZSBmb3IgdGhlbT8NCj4NCj4gVGhhbmtzDQog
ICAgIA==
