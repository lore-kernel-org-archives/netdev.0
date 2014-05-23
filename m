From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: skbuff truesize incorrect.
Date: Fri, 23 May 2014 15:30:37 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1724CACF@AcuExch.aculab.com>
References: <537E4AFD.20304@mentor.com>
		<1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>
		<063D6719AE5E284EB5DD2968C1650D6D1724C490@AcuExch.aculab.com>
	 <87r43k4yhe.fsf@nemi.mork.no>
	 <063D6719AE5E284EB5DD2968C1650D6D1724C7A1@AcuExch.aculab.com>
	 <537F2D53.5020408@mentor.com>
 <1400852843.5367.191.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: =?utf-8?B?J0Jqw7hybiBNb3JrJw==?= <bjorn@mork.no>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"kamal@canonical.com" <kamal@canonical.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"mszeredi@suse.cz" <mszeredi@suse.cz>,
	"fw@strlen.de" <fw@strlen.de>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59427 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751717AbaEWPbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 11:31:21 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17588-01 for <netdev@vger.kernel.org>;
 Fri, 23 May 2014 16:31:11 +0100 (BST)
In-Reply-To: <1400852843.5367.191.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQouLi4NCj4gVENQIHN0YWNrIHVzZXMgZmFzdCBjbG9uZXMsIGFu
ZCBjdXJyZW50IHN0YWNrIGdpdmVzIHRoZW0gYSB0cnVlc2l6ZSBvZg0KPiAyMDQ4ICsgc2l6ZW9m
KHNrX2J1ZmYpLCB3aGlsZSBpdCByZWFsbHkgc2hvdWxkIGJlIDIwNDggKw0KPiAyKnNpemVvZihz
a19idWZmKQ0KPiANCj4gTHVja2lseSwgR1NPL1RTTyB0ZW5kcyB0byByZWR1Y2UgdGhlIGVycm9y
LCBhcyBza2JzIG92ZXJoZWFkIGlzIGxvd2VyLg0KDQpEb2Vzbid0IHRoYXQgYWZmZWN0IHRoZSB0
eCBzaWRlIC0gd2hlcmUgdGhlIHRydWVzaXplIGRvZXNuJ3QgbWF0dGVyIGFzIG11Y2g/DQoNCglE
YXZpZA0KDQoNCg==
