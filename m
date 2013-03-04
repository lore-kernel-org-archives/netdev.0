From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: fec: fix build error in no MXC platform
Date: Mon, 04 Mar 2013 14:15:44 -0500 (EST)
Message-ID: <20130304.141544.1354907717393768867.davem@davemloft.net>
References: <1362379958-12972-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, B38611@freescale.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	gerg@uclinux.org, s.hauer@pengutronix.de
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758520Ab3CDTPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 14:15:46 -0500
In-Reply-To: <1362379958-12972-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRnJhbmsgTGkgPEZyYW5rLkxpQGZyZWVzY2FsZS5jb20+DQpEYXRlOiBNb24sIDQgTWFy
IDIwMTMgMTQ6NTI6MzggKzA4MDANCg0KPiBidWlsZCBlcnJvciBjYXVzZSBieQ0KPiBDb21taXQg
ZmY0M2RhODZjNjlkNzZhNzI2ZmZlN2QxNjY2MTQ4OTYwZGMxZDEwOA0KPiAoIk5FVDogRkVDOiBk
eW5hbXRpYyBjaGVjayBETUEgZGVzYyBidWZmIHR5cGUiKQ0KPiANCj4gZHJpdmVycy9uZXQvZXRo
ZXJuZXQvZnJlZXNjYWxlL2ZlYy5jOiBJbiBmdW5jdGlvbiChZmVjX2VuZXRfZ2V0X25leHRkZXNj
ojoNCj4gZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2ZlYy5jOjIxNToxODogZXJyb3I6
IGludmFsaWQgdXNlIG9mIHVuZGVmaW5lZCB0eXBlIKFzdHJ1Y3QgYnVmZGVzY19leKINCj4gZHJp
dmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2ZlYy5jOiBJbiBmdW5jdGlvbiChZmVjX2VuZXRf
Z2V0X3ByZXZkZXNjojoNCj4gZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2ZlYy5jOjIy
NDoxODogZXJyb3I6IGludmFsaWQgdXNlIG9mIHVuZGVmaW5lZCB0eXBlIKFzdHJ1Y3QgYnVmZGVz
Y19leKINCj4gZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2ZlYy5jOiBJbiBmdW5jdGlv
biChZmVjX2VuZXRfc3RhcnRfeG1pdKI6DQo+IGRyaXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVzY2Fs
ZS9mZWMuYzoyODY6Mzc6IGVycm9yOiBhcml0aG1ldGljIG9uIHBvaW50ZXIgdG8gYW4gaW5jb21w
bGV0ZSB0eXBlDQo+IGRyaXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVzY2FsZS9mZWMuYzoyODc6MTM6
IGVycm9yOiBhcml0aG1ldGljIG9uIHBvaW50ZXIgdG8gYW4gaW5jb21wbGV0ZSB0eXBlDQo+IGRy
aXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVzY2FsZS9mZWMuYzozMjQ6NzogZXJyb3I6IGRlcmVmZXJl
bmNpbmcgcG9pbnRlciB0byBpbmNvbXBsZXRlIHR5cGUgZXRjLi4uLg0KPiANCj4gU2lnbmVkLW9m
Zi1ieTogRnJhbmsgTGkgPEZyYW5rLkxpQGZyZWVzY2FsZS5jb20+DQoNCkFwcGxpZWQuDQo=
