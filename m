From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: Fix compilation warning in
 __bpf_lru_list_rotate_inactive
Date: Wed, 16 Nov 2016 11:32:44 -0500 (EST)
Message-ID: <20161116.113244.142339090478764244.davem@davemloft.net>
References: <1479236404-3906780-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43842 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751584AbcKPQcp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 11:32:45 -0500
In-Reply-To: <1479236404-3906780-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTWFydGluIEthRmFpIExhdSA8a2FmYWlAZmIuY29tPg0KRGF0ZTogVHVlLCAxNSBOb3Yg
MjAxNiAxMTowMDowNCAtMDgwMA0KDQo+IGdjYy02LjIuMSBnaXZlcyB0aGUgZm9sbG93aW5nIHdh
cm5pbmc6DQo+IGtlcm5lbC9icGYvYnBmX2xydV9saXN0LmM6IEluIGZ1bmN0aW9uIKFfX2JwZl9s
cnVfbGlzdF9yb3RhdGVfaW5hY3RpdmUuaXNyYS4zojoNCj4ga2VybmVsL2JwZi9icGZfbHJ1X2xp
c3QuYzoyMDE6Mjg6IHdhcm5pbmc6IKFuZXh0oiBtYXkgYmUgdXNlZCB1bmluaXRpYWxpemVkIGlu
IHRoaXMgZnVuY3Rpb24gWy1XbWF5YmUtdW5pbml0aWFsaXplZF0NCj4gDQo+IFRoZSAibmV4dCIg
aXMgY3VycmVudGx5IGluaXRpYWxpemVkIGluIHRoZSB3aGlsZSgpIGxvb3Agd2hpY2ggbXVzdCBo
YXZlID49MQ0KPiBpdGVyYXRpb25zLg0KPiANCj4gVGhpcyBwYXRjaCBpbml0aWFsaXplcyBuZXh0
IHRvIGdldCByaWQgb2YgdGhlIGNvbXBpbGVyIHdhcm5pbmcuDQo+IA0KPiBGaXhlczogM2EwOGMy
ZmQ3NjM0ICgiYnBmOiBMUlUgTGlzdCIpDQo+IFJlcG9ydGVkLWJ5OiBEYXZpZCBNaWxsZXIgPGRh
dmVtQGRhdmVtbG9mdC5uZXQ+DQo+IFNpZ25lZC1vZmYtYnk6IE1hcnRpbiBLYUZhaSBMYXUgPGth
ZmFpQGZiLmNvbT4NCg0KQXBwbGllZC4NCg==
