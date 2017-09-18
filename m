From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net_sched: use explicit size of struct tcmsg, remove
 need to declare tcm
Date: Mon, 18 Sep 2017 15:10:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0078B30@AcuExch.aculab.com>
References: <20170918114038.29741-1-colin.king@canonical.com>
         <063D6719AE5E284EB5DD2968C1650D6DD007891E@AcuExch.aculab.com>
 <1505746834.29839.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: 'Colin King' <colin.king@canonical.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:65521 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932478AbdIRPKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 11:10:43 -0400
In-Reply-To: <1505746834.29839.17.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDE4IFNlcHRlbWJlciAyMDE3IDE2OjAxDQouLi4N
Cj4gPiA+IC0JZXJyID0gbmxtc2dfcGFyc2UobmxoLCBzaXplb2YoKnRjbSksIHRjYSwgVENBX01B
WCwgTlVMTCwgTlVMTCk7DQo+ID4gPiArCWVyciA9IG5sbXNnX3BhcnNlKG5saCwgc2l6ZW9mKHN0
cnVjdCB0Y21zZyksIHRjYSwgVENBX01BWCwgTlVMTCwgTlVMTCk7DQo+ID4NCj4gPiBXb3VsZCBz
aXplb2YoKm5sbXNnX2RhdGEobmxoKSkgYmUgY2xlYW5lcj8/DQo+IA0KPiBOb3QgcmVhbGx5LCBz
aW5jZQ0KPiANCj4gc3RhdGljIGlubGluZSB2b2lkICpubG1zZ19kYXRhKGNvbnN0IHN0cnVjdCBu
bG1zZ2hkciAqbmxoKQ0KDQpJIHRob3VnaHQgYWJvdXQgdGhhdCBhZnRlciBwb3N0aW5nIDotKA0K
DQoJRGF2aWQNCg0K
