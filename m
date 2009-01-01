From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: Re: 2.6.28-03117: WARNING: at net/ipv4/tcp_input.c:2504 tcp_mark_head_lost()
Date: Thu, 1 Jan 2009 17:50:26 +0300
Message-ID: <a4423d670901010650iefe98e5je2e53d9f7d74df81@mail.gmail.com>
References: <20090101124114.GA4281@orion>
	 <Pine.LNX.4.64.0901011627020.4692@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: "=?UTF-8?Q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:15234 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756138AbZAAOu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2009 09:50:29 -0500
Received: by yw-out-2324.google.com with SMTP id 9so1902533ywe.1
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2009 06:50:26 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0901011627020.4692@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MjAwOS8xLzEgSWxwbyBKw6RydmluZW4gPGlscG8uamFydmluZW5AaGVsc2lua2kuZmk+Ogo+IE9u
IFRodSwgMSBKYW4gMjAwOSwgQWxleGFuZGVyIEJlcmVnYWxvdiB3cm90ZToKPgo+PiBXQVJOSU5H
OiBhdCBuZXQvaXB2NC90Y3BfaW5wdXQuYzoyNTA0IHRjcF9tYXJrX2hlYWRfbG9zdCsweDFkZi8w
eDIwMCgpCj4+ICBNb2R1bGVzIGxpbmtlZCBpbjogdzgzNjI3aGYgaHdtb25fdmlkIGkyY19uZm9y
Y2UyCj4+ICBQaWQ6IDAsIGNvbW06IHN3YXBwZXIgTm90IHRhaW50ZWQgMi42LjI4LTAzMTE3LWc2
YTk0Y2I3ICMxCj4+ICBDYWxsIFRyYWNlOgo+PiAgIFs8YzA0MGYzMjE+XSA/IHByaW50aysweDE4
LzB4MWYKPj4gICBbPGMwMTI4MzU0Pl0gd2Fybl9vbl9zbG93cGF0aCsweDU0LzB4ODAKPj4gICBb
PGMwMTRiZDI1Pl0gPyBfX2xvY2tfYWNxdWlyZSsweDJjNS8weDEwMDAKPj4gICBbPGMwMTRiNzRj
Pl0gPyB0cmFjZV9oYXJkaXJxc19vbl9jYWxsZXIrMHg3Yy8weDE2MAo+PiAgIFs8YzAzOTkwNDE+
XSA/IGRldl9xdWV1ZV94bWl0KzB4ZTEvMHg1ZDAKPj4gICBbPGMwMTRiZDI1Pl0gPyBfX2xvY2tf
YWNxdWlyZSsweDJjNS8weDEwMDAKPj4gICBbPGMwMTQ4NjJiPl0gPyB0cmFjZV9oYXJkaXJxc19v
ZmYrMHhiLzB4MTAKPj4gICBbPGMwM2JmYWZmPl0gdGNwX21hcmtfaGVhZF9sb3N0KzB4MWRmLzB4
MjAwCj4+ICAgWzxjMDNjNTYxZD5dIHRjcF9hY2srMHgxOGRkLzB4MWVmMAo+PiAgIFs8YzAzYzVl
Yzk+XSB0Y3BfcmN2X2VzdGFibGlzaGVkKzB4Mjk5LzB4NWIwCj4+ICAgWzxjMDNjYzg0MD5dIHRj
cF92NF9kb19yY3YrMHg5MC8weDFiMAo+Cj4gLi4uc25pcC4uLgo+Cj4gQ2FuIHlvdSByZXByb2R1
Y2UgaXQ/Ck5vLCBJIGRvIG5vdCBrbm93IGhvdyB0byByZXByb2R1Y2UgaXQuCg==
