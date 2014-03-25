From: "wei zhang" <asuka.com@163.com>
Subject: Re: [PATCH] ipv4: gre: Fix null pointer dereference in
 gre_cisco_err()
Date: Tue, 25 Mar 2014 16:56:20 +0800 (CST)
Message-ID: <232812eb.b291.144f87462d4.Coremail.asuka.com@163.com>
References: <1395646471-637-1-git-send-email-asuka.com@163.com>
 <20140324.151417.474668383309974516.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: xeb@mail.ru, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m13-127.163.com ([220.181.13.127]:37380 "EHLO m13-127.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830AbaCYJNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2014 05:13:16 -0400
In-Reply-To: <20140324.151417.474668383309974516.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

QXTCoDIwMTQtMDMtMjXCoDAzOjE0OjE3LCJEYXZpZMKgTWlsbGVyIsKgPGRhdmVtQGRhdmVtbG9m
dC5uZXQ+wqB3cm90ZToKPkZyb206wqBXZWnCoFpoYW5nwqA8YXN1a2EuY29tQDE2My5jb20+Cj5E
YXRlOsKgTW9uLMKgMjTCoE1hcsKgMjAxNMKgMTU6MzQ6MzHCoCswODAwCj4KPj7CoFdoZW7CoHVz
ZcKgdGhlwqBncmXCoHZwb3J0LMKgb3BlbnZzd2l0Y2jCoHJlZ2lzdGVywqBhwqBncmVfY2lzY29f
cHJvdG9jb2zCoGJ1dAo+PsKgZG9lc8Kgbm90wqBzdXBwbHnCoGHCoGVycl9oYW5kbGVywqB3aXRo
wqBpdC7CoFRoZcKgZ3JlX2Npc2NvX2VycigpwqBjYWxswqB0aGUKPj7CoGVycl9oYW5kbGVywqB3
aXRob3V0wqBleGlzdGVuY2XCoGNoZWNrLMKgY2F1c2XCoHRoZcKga2VybmVswqBjcmFzaC4KPj7C
oAo+PsKgVGhpc8KgcGF0Y2jCoGJhc2XCoG9uwqB2My4xNC1yYzcuwqBCdXTCoHRoZcKgYnVnwqBh
ZmZlY3TCoGFsbMKga2VybmVswqBuZXdlcsKgdGhhbgo+PsKgMy4xMSEKPj7CoAo+PsKgU2lnbmVk
LW9mZi1ieTrCoFdlacKgWmhhbmfCoDxhc3VrYS5jb21AMTYzLmNvbT4KPgo+UmF0aGVyLMKgb3Bl
bnZzd2l0Y2jCoHNob3VsZMKgcHJvdmlkZcKgYW7CoGFwcHJvcHJpYXRlwqAtPmVycl9oYW5kbGVy
KCnCoHRoYXQKPnJldHVybnPCoFBBQ0tFVF9SQ1ZEwqBvcsKgUEFDS0VUX1JFSkVDVC4KClRoYW5r
IHlvdSBmb3IgeW91ciBleHBsYW5hdGlvbiwgSSBtaXN1bmRlcnN0YW5kIGl0IC4KSSdtIHZlcnkg
c29ycnkgYWJvdXQgdGhpcyBib3RoZXJpbmchCgo+Cj5JJ23CoG5vdMKgYXBwbHlpbmfCoHRoaXPC
oHBhdGNoLg==
