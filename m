From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: forcedeth: fix compile warning of not used
 nv_set_tso function
Date: Tue, 19 Apr 2011 20:11:56 -0700 (PDT)
Message-ID: <20110419.201156.212695092.davem@davemloft.net>
References: <4DAE3768.9030807@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44536
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752351Ab1DTDMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 23:12:31 -0400
In-Reply-To: <4DAE3768.9030807@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogU2hhbiBXZWkgPHNoYW53ZWlAY24uZnVqaXRzdS5jb20+DQpEYXRlOiBXZWQsIDIwIEFw
ciAyMDExIDA5OjMxOjIwICswODAwDQoNCj4gRml4IHRoZSBiZWxvdyBjb21waWxlIHdhcm5pbmc6
DQo+IGRyaXZlcnMvbmV0L2ZvcmNlZGV0aC5jOjQyNjY6IHdhcm5pbmc6IKFudl9zZXRfdHNvoiBk
ZWZpbmVkIGJ1dCBub3QgdXNlZA0KPiANCj4gY29tbWl0IDU2OWUxNDYgY29udmVydHMgZm9yY2Vk
ZXRoIGRyaXZlciB0byB1c2UgaHdfZmVhdHVyZXMuDQo+IFNvLCBpbXBsZW1lbnQgZnVuY3Rpb24g
b2YgLnNldF90c28gaXMgYWJhbmRvbmVkLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogU2hhbiBXZWkg
PHNoYW53ZWlAY24uZnVqaXRzdS5jb20+DQoNCkFwcGxpZWQuDQo=
