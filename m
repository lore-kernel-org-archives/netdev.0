From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] openvswitch: Fix Frame-size larger than
 1024 bytes warning.
Date: Tue, 20 Sep 2016 22:54:46 -0400 (EDT)
Message-ID: <20160920.225446.871428722593245047.davem@davemloft.net>
References: <1474318260-16988-1-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60168 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753824AbcIUCys (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 22:54:48 -0400
In-Reply-To: <1474318260-16988-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogUHJhdmluIEIgU2hlbGFyIDxwc2hlbGFyQG92bi5vcmc+DQpEYXRlOiBNb24sIDE5IFNl
cCAyMDE2IDEzOjUwOjU5IC0wNzAwDQoNCj4gVGhlcmUgaXMgbm8gbmVlZCB0byBkZWNsYXJlIHNl
cGFyYXRlIGtleSBvbiBzdGFjaywNCj4gd2UgY2FuIGp1c3QgdXNlIHN3X2Zsb3ctPmtleSB0byBz
dG9yZSB0aGUga2V5IGRpcmVjdGx5Lg0KPiANCj4gVGhpcyBjb21taXQgZml4ZXMgZm9sbG93aW5n
IHdhcm5pbmc6DQo+IA0KPiBuZXQvb3BlbnZzd2l0Y2gvZGF0YXBhdGguYzogSW4gZnVuY3Rpb24g
oW92c19mbG93X2NtZF9uZXeiOg0KPiBuZXQvb3BlbnZzd2l0Y2gvZGF0YXBhdGguYzoxMDgwOjE6
IHdhcm5pbmc6IHRoZSBmcmFtZSBzaXplIG9mIDEwNDAgYnl0ZXMNCj4gaXMgbGFyZ2VyIHRoYW4g
MTAyNCBieXRlcyBbLVdmcmFtZS1sYXJnZXItdGhhbj1dDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBQ
cmF2aW4gQiBTaGVsYXIgPHBzaGVsYXJAb3ZuLm9yZz4NCg0KQXBwbGllZC4NCg==
