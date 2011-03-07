From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] s2io: fix uninitialized compile warning
Date: Mon, 07 Mar 2011 15:49:42 -0800 (PST)
Message-ID: <20110307.154942.27799579.davem@davemloft.net>
References: <4D70CBCE.4090306@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: ramkrishna.vepa@exar.com, sivakumar.subramani@exar.com,
	sreenivasa.honnur@exar.com, jon.mason@exar.com,
	netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53346
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751306Ab1CGXtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 18:49:04 -0500
In-Reply-To: <4D70CBCE.4090306@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogU2hhbiBXZWkgPHNoYW53ZWlAY24uZnVqaXRzdS5jb20+DQpEYXRlOiBGcmksIDA0IE1h
ciAyMDExIDE5OjIzOjU4ICswODAwDQoNCj4gDQo+IGRyaXZlcnMvbmV0L3MyaW8uYzo3NTU5OiB3
YXJuaW5nOiChdGNwX2xlbqIgbWF5IGJlIHVzZWQgdW5pbml0aWFsaXplZCBpbiB0aGlzIGZ1bmN0
aW9uDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBTaGFuIFdlaSA8c2hhbndlaUBjbi5mdWppdHN1LmNv
bT4NCg0KQXBwbGllZCwgdGhhbmtzLg0K
