From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] am2150: Update nmclan_cs.c to use update PCMCIA API
Date: Mon, 22 Sep 2014 14:28:19 -0400 (EDT)
Message-ID: <20140922.142819.1077548667368665453.davem@davemloft.net>
References: <1411032821-9753-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, rpao@paonet.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524AbaIVS2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 14:28:25 -0400
In-Reply-To: <1411032821-9753-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSmVmZiBLaXJzaGVyIDxqZWZmcmV5LnQua2lyc2hlckBpbnRlbC5jb20+DQpEYXRlOiBU
aHUsIDE4IFNlcCAyMDE0IDAyOjMzOjQxIC0wNzAwDQoNCj4gUmVzb2x2ZXMgY29tcGlsZSB3YXJu
aW5nIGFib3V0IHVzZSBvZiBhIGRlcHJlY2F0ZWQgZnVuY3Rpb24gY2FsbDoNCj4gZHJpdmVycy9u
ZXQvZXRoZXJuZXQvYW1kL25tY2xhbl9jcy5jOiBJbiBmdW5jdGlvbiChbm1jbGFuX2NvbmZpZ6I6
DQo+IGRyaXZlcnMvbmV0L2V0aGVybmV0L2FtZC9ubWNsYW5fY3MuYzo2MjQ6Mzogd2FybmluZzog
oXBjbWNpYV9yZXF1ZXN0X2V4Y2x1c2l2ZV9pcnGiIGlzIGRlcHJlY2F0ZWQgKGRlY2xhcmVkIGF0
IGluY2x1ZGUvcGNtY2lhL2RzLmg6MjEzKSBbLVdkZXByZWNhdGVkLWRlY2xhcmF0aW9uc10NCj4g
ICAgcmV0ID0gcGNtY2lhX3JlcXVlc3RfZXhjbHVzaXZlX2lycShsaW5rLCBtYWNlX2ludGVycnVw
dCk7DQo+IA0KPiBVcGRhdGVzIHBjbWNpYV9yZXF1ZXN0X2V4Y2x1c2l2ZV9pcnEoKSB0byBwY21j
aWFfcmVxdWVzdF9pcnEoKS4NCj4gDQo+IENDOiBSb2dlciBQYW8gPHJwYW9AcGFvbmV0Lm9yZz4N
Cj4gU2lnbmVkLW9mZi1ieTogSmVmZiBLaXJzaGVyIDxqZWZmcmV5LnQua2lyc2hlckBpbnRlbC5j
b20+DQoNCkFwcGxpZWQsIHRoYW5rcyBKZWZmLg0K
