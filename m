From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: fix warning when CONFIG_PM is defined but not
 CONFIG_PM_SLEEP
Date: Tue, 03 Jan 2012 13:53:48 -0500 (EST)
Message-ID: <20120103.135348.2267500403570148493.davem@davemloft.net>
References: <A0790551-53D4-4D01-AB38-615607BCF9CC@cs.washington.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: dhalperi@cs.washington.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41464 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516Ab2ACSxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 13:53:54 -0500
In-Reply-To: <A0790551-53D4-4D01-AB38-615607BCF9CC@cs.washington.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGFuaWVsIEhhbHBlcmluIDxkaGFscGVyaUBjcy53YXNoaW5ndG9uLmVkdT4NCkRhdGU6
IFR1ZSwgMyBKYW4gMjAxMiAwOTozNDo0OCAtMDgwMA0KDQo+IGRyaXZlcnMvbmV0L2V0aGVybmV0
L21hcnZlbGwvc2tnZS5jOjQwNDY6IHdhcm5pbmc6IKFza2dlX3N1c3BlbmSiIGRlZmluZWQgYnV0
IG5vdCB1c2VkDQo+IGRyaXZlcnMvbmV0L2V0aGVybmV0L21hcnZlbGwvc2tnZS5jOjQwNzE6IHdh
cm5pbmc6IKFza2dlX3Jlc3VtZaIgZGVmaW5lZCBidXQgbm90IHVzZWQNCj4gDQo+IFNpZ25lZC1v
ZmYtYnk6IERhbmllbCBIYWxwZXJpbiA8ZGhhbHBlcmlAY3Mud2FzaGluZ3Rvbi5lZHU+DQo+IENj
OiBTdGVwaGVuIEhlbW1pbmdlciA8c2hlbW1pbmdlckBsaW51eC1mb3VuZGF0aW9uLm9yZz4NCg0K
QXBwbGllZCB0byBuZXQtbmV4dCwgdGhhbmtzLg0K
