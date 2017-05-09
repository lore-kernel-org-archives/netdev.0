From: "Gao Feng" <gfree.wind@vip.163.com>
Subject: Re:Re: [PATCH net] driver: vrf: Fix one possible use-after-free
 issue
Date: Tue, 9 May 2017 17:41:57 +0800 (CST)
Message-ID: <39383de.68eb.15bec962fe1.Coremail.gfree.wind@vip.163.com>
References: <1494320069-39638-1-git-send-email-gfree.wind@vip.163.com>
 <20170509092102.GB16263@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        davem@davemloft.net, netdev@vger.kernel.org,
        "gfree.wind@foxmail.com" <gfree.wind@foxmail.com>
To: "Florian Westphal" <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m171-177.vip.163.com ([123.58.177.171]:21969 "EHLO
        m171-177.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753012AbdEIJra (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 05:47:30 -0400
In-Reply-To: <20170509092102.GB16263@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

QXQgMjAxNy0wNS0wOSAxNzoyMTowMiwgIkZsb3JpYW4gV2VzdHBoYWwiIDxmd0BzdHJsZW4uZGU+
IHdyb3RlOgo+Z2ZyZWUud2luZEB2aXAuMTYzLmNvbSA8Z2ZyZWUud2luZEB2aXAuMTYzLmNvbT4g
d3JvdGU6Cj4+IFdoZW4gb25lIG5ldGZpbHRlciBydWxlIG9yIGhvb2sgc3RvbGVzIHRoZSBza2Ig
YW5kIHJldHVybiBORl9TVE9MRU4sCj4+IGl0IG1lYW5zIHRoZSBza2IgaXMgdGFrZW4gYnkgdGhl
IHJ1bGUsIGFuZCBvdGhlciBtb2R1bGVzIHNob3VsZCBub3QKPj4gdG91Y2ggdGhpcyBza2IgZXZl
ci4gTWF5YmUgdGhlIHNrYiBpcyBxdWV1ZWQgb3IgZnJlZWQgZGlyZWN0bHkgYnkgdGhlCj4+IHJ1
bGUuCj4+IAo+PiBOb3cgdXNlcyB0aGUgbmZfaG9vayBpbnN0ZWFkIG9mIE5GX0hPT0sgdG8gZ2V0
IHRoZSByZXN1bHQgb2YgbmV0ZmlsdGVyLAo+PiBhbmQgY2hlY2sgdGhlIHJldHVybiB2YWx1ZSBv
ZiBuZl9ob29rLiBPbmx5IHdoZW4gaXRzIHZhbHVlIGVxdWFscyAxLCBpdAo+PiBtZWFucyB0aGUg
c2tiIGNvdWxkIGdvIGFoZWFkLiBPciByZXNldCB0aGUgc2tiIGFzIE5VTEwuCj4+IAo+PiBCVFcs
IGJlY2F1c2UgdnJmX3Jjdl9maW5pc2ggaXMgZW1wdHkgZnVuY3Rpb24sIHNvIG5lZWRuJ3QgaW52
b2tlIGl0Cj4+IGV2ZW4gdGhvdWdoIG5mX2hvb2sgcmV0dXJucyAxLgo+Cj5UaGF0cyBhIGJ1ZyB0
aGVuLgo+Cj5UaGUgb2tmbiAoaWYgY2FsbGVkKSB0YWtlcyBvd25lcnNoaXAgb2Ygc2tiIGFuZCBt
dXN0IGZyZWUgaXQgZXZlbnR1YWxseS4KPk90aGVyd2lzZSB1c2Vyc3BhY2UgcXVldWVpbmcgbGVh
a3Mgc2tiIG9uIHJlaW5qZWN0aW9uLgo+Cj4oc2VlIG5mX3JlaW5qZWN0KCkgYW5kIGl0cyB1c2Ug
b2Ygb2tmbigpKS4KClRoYW5rcywgSSBvbmx5IHRob3VnaHQgYWJvdXQgdGhlIHN0b2xlbiBjYXNl
IGxpa2Ugc3lucHJveHkgd2hpY2ggd291bGQgZnJlZSB0aGUgc2tiIGRpcmVjdGx5LAphbmQgZm9y
Z2V0IHRoZSB1c2Vyc3BhY2UgY291bGQgcmVpbmplY3QgdGhlIHNrYi4KCkkgd291bGQgdXBkYXRl
IHRoZSBwYXRjaC4KCkJlc3QgUmVnYXJkcwpGZW5n
