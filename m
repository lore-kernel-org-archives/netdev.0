From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net/usb: add sierra_net.c driver
Date: Tue, 27 Apr 2010 18:11:49 -0700 (PDT)
Message-ID: <20100427.181149.179278301.davem@davemloft.net>
References: <1272415711.10975.3.camel@Linuxdev4-laptop>
	<20100427.180732.121248582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: dbrownell@users.sourceforge.net, rfiler@sierrawireless.com,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: epasheva@sierrawireless.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54899
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755251Ab0D1BLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 21:11:44 -0400
In-Reply-To: <20100427.180732.121248582.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAyNyBB
cHIgMjAxMCAxODowNzozMiAtMDcwMCAoUERUKQ0KDQo+IEZyb206IEVsaW5hIFBhc2hldmEgPGVw
YXNoZXZhQHNpZXJyYXdpcmVsZXNzLmNvbT4NCj4gRGF0ZTogVHVlLCAyNyBBcHIgMjAxMCAxNzo0
ODozMSAtMDcwMA0KPiANCj4+IFN1YmplY3Q6IFtQQVRDSCB2NV0gbmV0L3VzYjogYWRkIHNpZXJy
YV9uZXQuYyBkcml2ZXINCj4gDQo+IEFwcGxpZWQsIGFsdGhvdWdoIEkgaGFkIHRvIG1hbnVhbGx5
IHJlbW92ZSB0aGUgc3RyYXkgZXh0cmENCj4gbmV3bGluZSBhdCB0aGUgZW5kIG9mIGRyaXZlcnMv
bmV0L3VzYi9zaWVycmFfbmV0LmMgd2hpY2ggR0lUDQo+IGNvbXBsYWlucyBhYm91dCB3aGVuIHRo
ZSBwYXRjaCBpcyBhcHBsaWVkLg0KDQpJIGFsc28gaGFkIHRvIGZpeCB1cCB0aGUgZm9sbG93aW5n
IHdhcm5pbmcgZHVyaW5nIHRoZSBidWlsZDoNCg0KZHJpdmVycy9uZXQvdXNiL3NpZXJyYV9uZXQu
YzogSW4gZnVuY3Rpb24goXNpZXJyYV9uZXRfcGFyc2VfbHNpojoNCmRyaXZlcnMvbmV0L3VzYi9z
aWVycmFfbmV0LmM6MzY1OiB3YXJuaW5nOiBmb3JtYXQgoSV1oiBleHBlY3RzIHR5cGUgoXVuc2ln
bmVkIGludKIsIGJ1dCBhcmd1bWVudCA3IGhhcyB0eXBlIKFsb25nIHVuc2lnbmVkIGludKINCg0K
InNpemVfdCIgb2JqZWN0cyBtdXN0IHVzZSB0aGUgInoiIGZvcm1hdCBzcGVjaWZpZXIsIHNvICIl
enUiIGlzIHdoYXQNCnNob3VsZCBoYXZlIGJlZW4gdXNlZCBoZXJlLg0K
