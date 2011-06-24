From: Scott Goldman <scottjg@vmware.com>
Subject: RE: [Pv-drivers] [PATCH] vmxnet3: Enable GRO support.
Date: Fri, 24 Jun 2011 16:23:50 -0700
Message-ID: <03E840D17E263A48A5766AD576E0423A0129262C0A@exch-mbx-111.vmware.com>
References: <1308947605-4300-1-git-send-email-jesse@nicira.com>
 <03E840D17E263A48A5766AD576E0423A0129262BB5@exch-mbx-111.vmware.com>
 <BANLkTi=OJSnGQ99cG-QaaxxMp1od3KGCKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:4484 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754857Ab1FXXXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 19:23:52 -0400
In-Reply-To: <BANLkTi=OJSnGQ99cG-QaaxxMp1od3KGCKQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBJIHJhbiBzb21lIGJlbmNobWFya3MgYW5kIGRvIHNlZSBhIHNsaWdodCBwZXJmb3JtYW5jZSBk
cm9wIHdpdGggR1JPDQo+IHdoZW4gTFJPIGlzIGFsc28gb24sIHNvIGl0IHNlZW1zIHJlYXNvbmFi
bGUgdG8gYXZvaWQgaXQgaW4gdGhhdA0KPiBzaXR1YXRpb24uICBJIGNhbiByZXN1Ym1pdCB3aXRo
IHRoYXQgY2hhbmdlLg0KDQpDb29sLCB0aGFua3MuDQoNCj4gQXMgYW4gYXNpZGUsIGluIG1hbnkg
Y2FzZXMgdGhlIGh5cGVydmlzb3IgYWN0dWFsbHkgaGFzIGFsbCBvZiB0aGUNCj4gaW5mb3JtYXRp
b24gdGhhdCBpcyBuZWNlc3NhcnkgdG8ga2VlcCBMUk8gb24gYnV0IGRvZXMgbm90IHByb3ZpZGUg
aXQNCj4gdG8gdGhlIGd1ZXN0LiAgRm9yIGV4YW1wbGUsIGluIHRoZSBWTS10by1WTSBjYXNlIHRo
ZSBNU1MgaXMgcHJvdmlkZWQNCj4gYnkgdGhlIHNlbmRlciBhcyBwYXJ0IG9mIHRoZSBUU08gZGVz
Y3JpcHRvciBhbmQgaWYgZ2l2ZW4gdG8gdGhlDQo+IHJlY2VpdmVyIHdlIGNvdWxkIGdlbmVyYXRl
IGEgR1NPIGZyYW1lIGFuZCBhdm9pZCB0aGUgbmVlZCB0byBkbyBHUk8gaW4NCj4gdGhlIGZpcnN0
IHBsYWNlLiAgRG8geW91IGtub3cgaWYgaXQgaXMgcG9zc2libGUgdG8gZG8gdGhpcz8NCg0KSSB0
aGluayB0aGF0IHNvdW5kcyBsaWtlIGEgcHJldHR5IGdvb2QgaWRlYSwgYnV0IGlmIEkgdW5kZXJz
dGFuZCBjb3JyZWN0bHksIHRoYXQgY2hhbmdlIG5lZWRzIHRvIGdvIGluIHRoZSBoeXBlcnZpc29y
LCBub3QganVzdCB0aGUgZHJpdmVyLiBUaGUgZGV2aWNlIGVtdWxhdGlvbiBiYWNrZW5kIG5lZWRz
IHRvIHBvcHVsYXRlIHRoYXQgTVNTIHNvbWV3aGVyZSBpbiB0aGUgcmVjZWl2ZSBkZXNjcmlwdG9y
LiBJIHdpbGwgZmlsZSBhbiBpbnRlcm5hbCBidWcgYWJvdXQgaXQsIGJ1dCBqdXN0IHRvIHNldCBl
eHBlY3RhdGlvbnMsIEVTWCA1LjAgaXMgYWJvdXQgdG8gYmUgcmVsZWFzZWQsIHNvIHJlYWxpc3Rp
Y2FsbHkgYXQgdGhlIGVhcmxpZXN0LCB0aGlzIGNoYW5nZSBtYXkgbm90IGJlIHB1YmxpY2FsbHkg
YXZhaWxhYmxlIGZvciBhbm90aGVyIHllYXIuDQoJDQotc2pnDQoNClAuUy4gUm9uZ2h1YSwgdGhl
IHZteG5ldDMgbWFzdGVybWluZCwgd29ya3MgYXQgTmljaXJhIG5vdy4gSWYgeW91IHNlZSBoaW0s
IHRlbGwgaGltIEkgc2FpZCBoaS4NCg==
