From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 0/2] Pack struct xfrm_usersa_info and struct
 xfrm_userpolicy_info
Date: Thu, 9 Jan 2014 09:07:39 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D455E6C@AcuExch.aculab.com>
References: <1389077339-12814-1-git-send-email-fan.du@windriver.com>
 <20140107074724.GV31491@secunet.com> <52CBB3FC.9050207@windriver.com>
 <063D6719AE5E284EB5DD2968C1650D6D453AEE@AcuExch.aculab.com>
 <52CE5F21.1070800@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"dev@lists.strongswan.org" <dev@lists.strongswan.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Fan Du' <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45405 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752129AbaAIJJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 04:09:27 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 29851-07 for <netdev@vger.kernel.org>;
 Thu,  9 Jan 2014 09:09:23 +0000 (GMT)
In-Reply-To: <52CE5F21.1070800@windriver.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBGYW4gRHUgDQo+ID4gUGFja2luZyB0aGUgc3RydWN0dXJlcyBpcyBkZWZpbml0ZWx5
IHdyb25nLiBTb21lIDMyYml0IHN5c3RlbXMgKElJUkMgc3BhcmMpDQo+ID4gYWxpZ24gNjRiaXQg
aXRlbXMgb24gOCBieXRlIGJvdW5kYXJpZXMuIE5vdCB0byBtZW50aW9uIHRoZSBleHBlbnNpdmUg
Ynl0ZQ0KPiA+IGJ5IGJ5dGUgYWNjZXNzZXMgdGhpcyBmb3JjZXMgb24gc29tZSBzeXN0ZW1zLg0K
Pg0KPiBJIGRvbid0IGtub3cgbXVjaCBhYm91dCBzcGFyYywgaWYgSSByZWFkIHlvdXIgbWVzc2Fn
ZSByaWdodCwgeW91IG1lYW4gMzJiaXQgc3BhcmMNCj4gc3lzdGVtIGFsc28gaGFzIHBhZGRpbmcg
ZXZlbiBpZiBwYWNrIGF0dHJpYnV0ZSBpcyBzdXBwbGllZC4NCg0KV2l0aG91dCBwYWNraW5nOg0K
T24gMzJiaXQgeDg2IDY0Yml0IGludGVnZXJzIGFyZSBhbGlnbmVkIG9uIDRieXRlIGJvdW5kYXJp
ZXMuDQpPbiAzMmJpdCBzcGFyYyA2NGJpdCBpbnRlZ2VycyBhcmUgYWxpZ25lZCBvbiA4Ynl0ZSBi
b3VuZGFyaWVzLg0KDQpJZiB0aGUgc3RydWN0dXJlIGlzIHBhY2tlZCB0aGVuLCBmb3Igc3BhcmMg
KGV0YyksIHRoZSBjb21waWxlciBoYXMNCnRvIGdlbmVyYXRlIGNvZGUgdG8gcmVhZCBldmVyeXRo
aW5nIHVzaW5nIGJ5dGUgYWNjZXNzZXMuDQoNCglEYXZpZA0KDQo=
