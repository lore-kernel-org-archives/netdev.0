From: "Gao Feng" <gfree.wind@vip.163.com>
Subject: Re:Re: [PATCH net-next ] net: Remove useless function
 skb_header_release
Date: Thu, 21 Sep 2017 13:07:58 +0800 (CST)
Message-ID: <759c980e.47d8.15ea2d5de95.Coremail.gfree.wind@vip.163.com>
References: <1505968771-92232-1-git-send-email-gfree.wind@vip.163.com>
 <1505969350.12311.20.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m175-177.vip.163.com ([123.58.177.175]:29610 "EHLO
        m175-177.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdIUFN0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 01:13:26 -0400
In-Reply-To: <1505969350.12311.20.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pk9uIFRodSwgMjAxNy0wOS0yMSBhdCAxMjozOSArMDgwMCwgZ2ZyZWUud2luZEB2aXAuMTYzLmNv
bSB3cm90ZToKPj4gRnJvbTogR2FvIEZlbmcgPGdmcmVlLndpbmRAdmlwLjE2My5jb20+Cj4+IAo+
PiBUaGVyZSBpcyBubyBvbmUgd2hpY2ggd291bGQgaW52b2tlcyB0aGUgZnVuY3Rpb24gc2tiX2hl
YWRlcl9yZWxlYXNlLgo+PiBTbyBqdXN0IHJlbW92ZSBpdCBub3cuCj4KPlRoaXMgaW4gaW5jb21w
bGV0ZS4KPlRoZXJlIGFyZSBvdGhlciByZWZlcmVuY2VzIHRvIHRoaXMgZnVuY3Rpb24uCj4KPiQg
Z2l0IGdyZXAgLXcgc2tiX2hlYWRlcl9yZWxlYXNlCj5kcml2ZXJzL25ldC91c2IvYXNpeF9jb21t
b24uYzoJwqAqIFRDUCBwYWNrZXRzIGZvciBleGFtcGxlIGFyZSBjbG9uZWQsIGJ1dCBza2JfaGVh
ZGVyX3JlbGVhc2UoKQo+aW5jbHVkZS9saW51eC9za2J1ZmYuaDogKglza2JfaGVhZGVyX3JlbGVh
c2UgLSByZWxlYXNlIHJlZmVyZW5jZSB0byBoZWFkZXIKPmluY2x1ZGUvbGludXgvc2tidWZmLmg6
c3RhdGljIGlubGluZSB2b2lkIHNrYl9oZWFkZXJfcmVsZWFzZShzdHJ1Y3Qgc2tfYnVmZiAqc2ti
KQo+aW5jbHVkZS9saW51eC9za2J1ZmYuaDogKglWYXJpYW50IG9mIHNrYl9oZWFkZXJfcmVsZWFz
ZSgpIGFzc3VtaW5nIHNrYiBpcyBwcml2YXRlIHRvIGNhbGxlci4KPm5ldC9iYXRtYW4tYWR2L3Nv
ZnQtaW50ZXJmYWNlLmM6CcKgKiBkYXRhIHVzaW5nIHNrYl9oZWFkZXJfcmVsZWFzZSBpbiBvdXIg
c2ticyB0byBhbGxvdyBza2JfY293X2hlYWRlciB0bwoKQnV0IHRoZXJlIGFyZSBjb21tZW50cywg
bm90IHJlYWwgY29kZXMuCgpVbmxlc3MgdGhlIHNrYl9oZWFkZXJfcmVsZWFzZSBtYXkgYmUgdXNl
ZCBpbiB0aGUgZXh0ZXJuYWwgbW9kdWxlcwoKQmVzdCBSZWdhcmRzCkZlbmcK
