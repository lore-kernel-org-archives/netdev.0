From: <Sathya.Perla@Emulex.Com>
Subject: RE: Difficulties to get 1Gbps on be2net ethernet card
Date: Wed, 30 May 2012 03:04:50 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F647C678B73F@EXMAIL.ad.emulex.com>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
 <1338360536.2760.85.camel@edumazet-glaptop>
 <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
 <1338361587.2760.94.camel@edumazet-glaptop>
 <CAL8zT=jHWhDdv-DyXL8XnL8qRc7o-jZfA7ADU-qt54hB5aLyCw@mail.gmail.com>
 <CAL8zT=gJT1Frn_44SU0CrpZjPxwC_VuHFE4k9jvOGNmFomzhHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>
To: <jhautbois@gmail.com>, <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:44478 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751161Ab2E3KFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 06:05:14 -0400
In-Reply-To: <CAL8zT=gJT1Frn_44SU0CrpZjPxwC_VuHFE4k9jvOGNmFomzhHA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogbmV0ZGV2LW93bmVyQHZnZXIua2Vy
bmVsLm9yZyBbbWFpbHRvOm5ldGRldi1vd25lckB2Z2VyLmtlcm5lbC5vcmddIE9uDQo+QmVoYWxm
IE9mIEplYW4tTWljaGVsIEhhdXRib2lzDQo+DQo+MjAxMi81LzMwIEplYW4tTWljaGVsIEhhdXRi
b2lzIDxqaGF1dGJvaXNAZ21haWwuY29tPjoNCj4NCj5JIHVzZWQgdm1zdGF0IGluIG9yZGVyIHRv
IHNlZSB0aGUgZGlmZmVyZW5jZXMgYmV0d2VlbiB0aGUgdHdvIGtlcm5lbHMuDQo+VGhlIG1haW4g
ZGlmZmVyZW5jZSBpcyB0aGUgbnVtYmVyIG9mIGludGVycnVwdHMgcGVyIHNlY29uZC4NCj5JIGhh
dmUgYW4gYXZlcmFnZSBvZiA4NzUwMCBvbiAzLjIgYW5kIDc1MDAgb24gMi42LCAxMCB0aW1lcyBs
b3dlciAhDQo+SSBzdXNwZWN0IHRoZSBiZTJuZXQgZHJpdmVyIHRvIGJlIHRoZSBtYWluIGNhdXNl
LCBhbmQgSSBjaGVja2VzIHRoZQ0KPi9wcm9jL2ludGVycnVwdHMgZmlsZSBpbiBvcmRlciB0byBi
ZSBzdXJlLg0KPg0KPkkgaGF2ZSBmb3IgZXRoMS10eCBvbiAyLjYuMjYgYWJvdXQgMjIwMCBpbnRl
cnJ1cHRzIHBlciBzZWNvbmQgYW5kIDIzMDAwIG9uIDMuMi4NCj5CVFcsIGl0IGlzIG5hbWVkIGV0
aDEtcTAgb24gMy4yIChhbmQgdHggYW5kIHJ4IGFyZSB0aGUgc2FtZSBJUlEpDQo+d2hlcmVhcyB0
aGVyZSBpcyBldGgxLXJ4MCBhbmQgZXRoMS10eCBvbiAyLjYuMjYuDQoNClllcywgdGhlcmUgaXMg
YW4gaXNzdWUgd2l0aCBiZTJuZXQgaW50ZXJydXB0IG1pdGlnYXRpb24gaW4gdGhlIHJlY2VudCBj
b2RlIHdpdGgNClJYIGFuZCBUWCBvbiB0aGUgc2FtZSBFdnQtUSAoY29tbWl0IDEwZWY5YWI0KS4g
VGhlIGhpZ2ggaW50ZXJydXB0IHJhdGUgaGFwcGVucyB3aGVuIGEgVFggYmxhc3QgaXMNCmRvbmUg
d2hpbGUgUlggaXMgcmVsYXRpdmVseSBzaWxlbnQgb24gYSBxdWV1ZSBwYWlyLiBJbnRlcnJ1cHQg
cmF0ZSBkdWUgdG8gVFggY29tcGxldGlvbnMgaXMgbm90IGJlaW5nDQptaXRpZ2F0ZWQuDQoNCkkg
aGF2ZSBhIGZpeCBhbmQgd2lsbCBzZW5kIGl0IG91dCBzb29uLi4NCg0KdGhhbmtzLA0KLVNhdGh5
YQ0K
