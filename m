From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macb: don't use platform_set_drvdata() on a net_device
Date: Mon, 28 Feb 2011 12:22:33 -0800 (PST)
Message-ID: <20110228.122233.115936736.davem@davemloft.net>
References: <1298901925-16525-1-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, nicolas.ferre@atmel.com
To: jamie@jamieiles.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43328
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754729Ab1B1UV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 15:21:56 -0500
In-Reply-To: <1298901925-16525-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSmFtaWUgSWxlcyA8amFtaWVAamFtaWVpbGVzLmNvbT4NCkRhdGU6IE1vbiwgMjggRmVi
IDIwMTEgMTQ6MDU6MjUgKzAwMDANCg0KPiBDb21taXQgNzFkNjQyOSAoRHJpdmVyIGNvcmU6IGNv
bnZlcnQgcGxhdGZvcm1fe2dldCxzZXR9X2RydmRhdGEgdG8NCj4gc3RhdGljIGlubGluZSBmdW5j
dGlvbnMpIG5vdyB0cmlnZ2VycyBhIHdhcm5pbmcgaW4gdGhlIG1hY2IgbmV0d29yaw0KPiBkcml2
ZXI6DQo+IA0KPiAgIENDICAgICAgZHJpdmVycy9uZXQvbWFjYi5vDQo+IGRyaXZlcnMvbmV0L21h
Y2IuYzogSW4gZnVuY3Rpb24goW1hY2JfbWlpX2luaXSiOg0KPiBkcml2ZXJzL25ldC9tYWNiLmM6
MjYzOiB3YXJuaW5nOiBwYXNzaW5nIGFyZ3VtZW50IDEgb2YgoXBsYXRmb3JtX3NldF9kcnZkYXRh
oiBmcm9tIGluY29tcGF0aWJsZSBwb2ludGVyIHR5cGUNCj4gaW5jbHVkZS9saW51eC9wbGF0Zm9y
bV9kZXZpY2UuaDoxMzg6IG5vdGU6IGV4cGVjdGVkIKFzdHJ1Y3QgcGxhdGZvcm1fZGV2aWNlICqi
IGJ1dCBhcmd1bWVudCBpcyBvZiB0eXBlIKFzdHJ1Y3QgbmV0X2RldmljZSAqog0KPiANCj4gVXNl
IGRldl9zZXRfZHJ2ZGF0YSgpIG9uIHRoZSBkZXZpY2UgZW1iZWRkZWQgaW4gdGhlIG5ldF9kZXZp
Y2UgaW5zdGVhZC4NCj4gDQo+IENjOiBOaWNvbGFzIEZlcnJlIDxuaWNvbGFzLmZlcnJlQGF0bWVs
LmNvbT4NCj4gU2lnbmVkLW9mZi1ieTogSmFtaWUgSWxlcyA8amFtaWVAamFtaWVpbGVzLmNvbT4N
Cg0KQXBwbGllZC4NCg==
