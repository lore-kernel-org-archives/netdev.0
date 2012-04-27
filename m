From: <Somnath.Kotur@Emulex.Com>
Subject: RE: [PATCH net-next 2/5] be2net: Fix to allow setting of debug
 levels in the firmware.
Date: Thu, 26 Apr 2012 23:46:06 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F6440F8979D6@EXMAIL.ad.emulex.com>
References: <464dcb28-2450-4e0b-a30f-d8c9104bac86@exht1.ad.emulex.com>
 <1335461388.2712.25.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>
To: <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:2276 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752057Ab2D0Gq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 02:46:29 -0400
In-Reply-To: <1335461388.2712.25.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IFRoaXMgb3BlcmF0aW9uIGlzIGludGVuZGVkIGZvciBjb250cm9sbGluZyBsb2dnaW5nIGJ5
IHRoZSBkcml2ZXIsIGFuZCB0aGUgZmxhZ3MNCj4gYXJlIGRlZmluZWQgaW4gPGxpbnV4L25ldGRl
dmljZS5oPi4gIChOb3QgZXhwb3J0ZWQgdG8gdXNlcmxhbmQgeWV0LCBidXQNCj4gZXRodG9vbCBr
bm93cyB0aGVpciBuYW1lcy4pDQo+IA0KPiBJZiB5b3VyIGZpcm13YXJlIHN1cHBvcnRzIHNvbWUg
a2luZCBvZiBsb2dnaW5nIHRoZW4gaXQgbWF5IGJlIHJlYXNvbmFibGUgdG8NCj4gaGF2ZSB0aGlz
IGNvbnRyb2wgYm90aCBkcml2ZXIgYW5kIGZpcm13YXJlLCBidXQgbm90ICpqdXN0KiB0aGUgZmly
bXdhcmUuDQpUaGFua3MgZm9yIHlvdXIgY29tbWVudHMgQmVuLg0KDQpDdXJyZW50bHkgdGhlIGRy
aXZlciBsb2dzIG9ubHkgYSB2ZXJ5IGZldyBjcml0aWNhbCBlcnJvcnMvd2FybmluZ3M7IHNvIHdl
IGZlbHQgaXQgbWlnaHQgYmUgYW4gb3ZlcmtpbGwgdG8gDQpkZWZpbmUgZHJpdmVyIGxvZyBsZXZl
bHMuDQpPbiB0aGUgb3RoZXIgaGFuZCwgdGhlIEYvVyBoYXMgZXh0ZW5zaXZlIGxvZ2dpbmcgYW5k
IHRyYWNpbmcgZmFjaWxpdHkgYW5kIHRoZSBldGh0b29sICdtc2dsZXZlbCcgb3B0aW9uIHNlZW1l
ZCANCmxpa2UgYSByZWFzb25hYmxlIG1ldGhvZCBmb3IgY29udHJvbGxpbmcgdGhlIGxvZ2dpbmcg
bGV2ZWwuDQoNCj4gDQo+IFlvdSBzaG91bGQgYWxzbyBpbXBsZW1lbnQgdGhlIGdldF9tc2dsZXZl
bCBvcGVyYXRpb24gYXQgdGhlIHNhbWUgdGltZS4NCg0KWWVzIHlvdSBhcmUgY29ycmVjdC4gV2Ug
d2lsbCBpbXBsZW1lbnQgdGhlIGdldF9tc2dsZXZlbCBhbmQgcmUtcG9zdCB0aGUgcGF0Y2guDQo+
IA0KPiBCZW4uDQo+IA0KDQpUaGFua3MNClNvbQ0K
