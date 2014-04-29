From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 5/7] net:fec: add support for dumping transmit
 ring on timeout
Date: Tue, 29 Apr 2014 14:01:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F701524@AcuExch.aculab.com>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
	<1398773350-7293-5-git-send-email-Frank.Li@freescale.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F7014F0@AcuExch.aculab.com>
 <CAHrpEqSCSw=bYgx5Egk4Mva-CODnw5=vvK6y3VWmB3_QpBQ8sQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Frank Li <Frank.Li@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"B38611@freescale.com" <B38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"rmk+kernel@arm.linux.org.uk" <rmk+kernel@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Frank Li' <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50787 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757454AbaD2ODs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 10:03:48 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31846-03 for <netdev@vger.kernel.org>;
 Tue, 29 Apr 2014 15:03:47 +0100 (BST)
In-Reply-To: <CAHrpEqSCSw=bYgx5Egk4Mva-CODnw5=vvK6y3VWmB3_QpBQ8sQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRnJhbmsgLi4uDQo+ID4gWW91IHByb2JhYmx5IHdhbnQgdGhlIHJlYWQgYW5kIHdyaXRl
IGluZGV4ZXMgYXMgd2VsbC4NCj4gDQo+ICAgICAgICAgICAgICAgICAgICAgIGJkcCA9PSBmZXAt
PmN1cl90eCA/ICdTJyA6ICcgJywNCj4gICAgICAgICAgICAgICAgICAgICAgYmRwID09IGZlcC0+
ZGlydHlfdHggPyAnSCcgOiAnICcsDQo+IA0KPiBBYm92ZSBjb2RlIGFscmVhZHkgcHJpbnQgcmVh
ZCBhbmQgd3JpdGUgaW5kZXguICdTJywgJ0gnDQoNCkdhaCBJIG11c3QgYmUgYXNsZWVwIQ0KU29t
ZXRoaW5nIG1hZGUgYmUgdGhpbmsgdGhhdCB3YXMgdG8gZG8gd2l0aCB0aGUgcmluZyBvd25lcnNo
aXAgYml0IQ0KDQoJRGF2aWQNCg0K
