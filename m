From: "Gao Feng" <gfree.wind@vip.163.com>
Subject: Re:Re: [PATCH net-next] net: rps: Add the rfs_needed check when
 record flow hash
Date: Fri, 26 May 2017 08:32:53 +0800 (CST)
Message-ID: <232a9725.7cb5.15c422b9d3b.Coremail.gfree.wind@vip.163.com>
References: <1495611359-118199-1-git-send-email-gfree.wind@vip.163.com>
 <20170525.131141.1106125565617394205.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>,
        "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m171-177.vip.163.com ([123.58.177.171]:43200 "EHLO
        m171-177.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936174AbdEZAdG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 20:33:06 -0400
In-Reply-To: <20170525.131141.1106125565617394205.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgRGF2aWQgJiBFcmljLAoKQXQgMjAxNy0wNS0yNiAwMToxMTo0MSwgIkRhdmlkIE1pbGxlciIg
PGRhdmVtQGRhdmVtbG9mdC5uZXQ+IHdyb3RlOgo+RnJvbTogZ2ZyZWUud2luZEB2aXAuMTYzLmNv
bQo+RGF0ZTogV2VkLCAyNCBNYXkgMjAxNyAxNTozNTo1OSArMDgwMAo+Cj4+ICAKPj4gK3N0YXRp
YyBpbmxpbmUgdm9pZCBzb2NrX3Jwc19yZWNvcmRfZmxvd19oYXNoKF9fdTMyIGhhc2gpCj4+ICt7
Cj4+ICsjaWZkZWYgQ09ORklHX1JQUwo+PiArCWlmIChzdGF0aWNfa2V5X2ZhbHNlKCZyZnNfbmVl
ZGVkKSkKPj4gKwkJX3NvY2tfcnBzX3JlY29yZF9mbG93X2hhc2goaGFzaCk7Cj4+ICsjZW5kaWYK
Pj4gK30KPj4gKwo+Cj5UaGlzIGlzIG5vIGxvbmdlciB1c2VkLgo+Cj5JZiB5b3UgaGF2ZSBzb21l
IHBsYW5zIHRvIHVzZSBpdCBpbiBhbm90aGVyIGNvbnRleHQsIHlvdSBhYnNvbHV0ZWx5IF9NVVNU
Xwo+cG9zdCB0aGlzIGNoYW5nZSBpbnNpZGUgb2YgYSBwYXRjaCBzZXJpZXMgdGhhdCBhZGRzIHRo
ZSBuZXcgdXNlciBhcyB3ZWxsLgo+Cj5PdGhlcndpc2UgaXQgaXMgaW1wb3NzaWJsZSB0byBkZXRl
cm1pbmUgdGhlIGNvcnJlY3RuZXNzIGFuZAo+YXBwcm9wcmlhdGVuZXNzIG9mIHlvdXIgY2hhbmdl
cy4KPgo+VGhhbmtzLgoKVGhlIHNvY2tfcnBzX3JlY29yZF9mbG93X2hhc2ggaXMgc3RpbGwgdXNl
ZCBub3cuClRoZXJlIGlzIG9ubHkgb25lIGNhbGxlciB3aGljaCBpcyB0dW5fZmxvd191cGRhdGUg
aW4gZmlsZSB0dW4uYy4KCkJlc3QgUmVnYXJkcwpGZW5nCgo=
