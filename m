From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: add dependency on HAS_IOMEM to
 MDIO_BUS_MUX_MMIOREG
Date: Wed, 08 Jul 2015 14:11:06 -0700 (PDT)
Message-ID: <20150708.141106.1594089175899221214.davem@davemloft.net>
References: <1436116587-1982-1-git-send-email-robh@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: robh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758852AbbGHVLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 17:11:07 -0400
In-Reply-To: <1436116587-1982-1-git-send-email-robh@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogUm9iIEhlcnJpbmcgPHJvYmhAa2VybmVsLm9yZz4NCkRhdGU6IFN1biwgIDUgSnVsIDIw
MTUgMTI6MTY6MjcgLTA1MDANCg0KPiBPbiBVTUwgYnVpbGRzLCBtZGlvLW11eC1tbWlvcmVnLmMg
ZmFpbHMgdG8gY29tcGlsZToNCj4gDQo+IGRyaXZlcnMvbmV0L3BoeS9tZGlvLW11eC1tbWlvcmVn
LmM6NTA6MzogZXJyb3I6IGltcGxpY2l0IGRlY2xhcmF0aW9uIG9mIGZ1bmN0aW9uIKFpb3JlbWFw
oiBbLVdlcnJvcj1pbXBsaWNpdC1mdW5jdGlvbi1kZWNsYXJhdGlvbl0NCj4gZHJpdmVycy9uZXQv
cGh5L21kaW8tbXV4LW1taW9yZWcuYzo2MzozOiBlcnJvcjogaW1wbGljaXQgZGVjbGFyYXRpb24g
b2YgZnVuY3Rpb24goWlvdW5tYXCiIFstV2Vycm9yPWltcGxpY2l0LWZ1bmN0aW9uLWRlY2xhcmF0
aW9uXQ0KPiANCj4gVGhpcyBpcyBkdWUgdG8gQ09ORklHX09GIG5vdyBiZWluZyB1c2VyIHNlbGVj
dGFibGUuIEFkZCBhIGRlcGVuZGVuY3kgb24NCj4gSEFTX0lPTUVNIHRvIGZpeCB0aGlzLg0KPiAN
Cj4gU2lnbmVkLW9mZi1ieTogUm9iIEhlcnJpbmcgPHJvYmhAa2VybmVsLm9yZz4NCg0KQXBwbGll
ZCwgdGhhbmtzLg0K
