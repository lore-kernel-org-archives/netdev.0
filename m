From: Roy Pledge <roy.pledge@freescale.com>
Subject: RE: [PATCH 02/11] soc/fsl: Introduce DPAA BMan device management
 driver
Date: Fri, 10 Jul 2015 20:57:53 +0000
Message-ID: <BN3PR0301MB12673A340E327986F0BC39E58C9F0@BN3PR0301MB1267.namprd03.prod.outlook.com>
References: <1436473322-21247-1-git-send-email-Roy.Pledge@freescale.com>
	 <1436473322-21247-3-git-send-email-Roy.Pledge@freescale.com>
	 <1436528160.20619.159.camel@tiscali.nl>
 <1436549595.2658.159.camel@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Scott Wood <scottwood@freescale.com>,
	Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0129.outbound.protection.outlook.com ([65.55.169.129]:11136
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754253AbbGJU55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jul 2015 16:57:57 -0400
In-Reply-To: <1436549595.2658.159.camel@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiANCj4gT24gRnJpLCAyMDE1LTA3LTEwIGF0IDEzOjM2ICswMjAwLCBQYXVsIEJvbGxlIHdyb3Rl
Og0KPiA+IE9uIGRvLCAyMDE1LTA3LTA5IGF0IDE2OjIxIC0wNDAwLCBSb3kgUGxlZGdlIHdyb3Rl
Og0KPiA+ID4gKyNpZmRlZiBDT05GSUdfRlNMX0RQQV9DSEVDS0lORw0KPiA+ID4gKyNkZWZpbmUg
RFBBX0FTU0VSVCh4KSBcDQo+ID4gPiArICAgZG8geyBcDQo+ID4gPiArICAgICAgICAgICBpZiAo
ISh4KSkgeyBcDQo+ID4gPiArICAgICAgICAgICAgICAgICAgIHByX2NyaXQoIkFTU0VSVDogKCVz
OiVkKSAlc1xuIiwgX19GSUxFX18sIF9fTElORV9fLCBcDQo+ID4gPiArICAgICAgICAgICAgICAg
ICAgICAgICAgICAgX19zdHJpbmdpZnlfMSh4KSk7IFwNCj4gPiA+ICsgICAgICAgICAgICAgICAg
ICAgZHVtcF9zdGFjaygpOyBcDQo+ID4gPiArICAgICAgICAgICAgICAgICAgIHBhbmljKCJhc3Nl
cnRpb24gZmFpbHVyZSIpOyBcDQo+ID4NCj4gPiBOb3QgbXkgY2FsbCwgYnV0IHdoeSBwYW5pYygp
IGhlcmU/DQo+IA0KPiBJJ20gcHJldHR5IHN1cmUgSSd2ZSBjb21wbGFpbmVkIGFib3V0IHRoaXMg
YmVmb3JlIChhcyB3ZWxsIGFzIGFsbCB0aGUNCj4gQlVHX09OcykuDQo+IA0KSXMgdGhlIGNvbmNl
cm4gaGVyZSBqdXN0IHRoZSBjYWxsIHRvIHBhbmljKCk/ICBJJ20gaGFwcHkgdG8gY2hhbmdlIHdo
YXQgaGFwcGVucyB3aGVuIGFuIGlzc3VlIGlzIGRldGVjdGVkIGJ1dCB0aGUgRFBBX0FTU0VSVCgp
IGNhbGxzIGFyZSB2ZXJ5IHVzZWZ1bCB3aGVuIHRlc3RpbmcgY2hhbmdlcyB0byB0aGUgZHJpdmVy
IGFuZCB3aGVuIGJyaW5naW5nIHVwIHRoZSBkcml2ZXJzIG9uIG5ldyBzaWxpY29uIHZhcmlhbnRz
LiANCg==
