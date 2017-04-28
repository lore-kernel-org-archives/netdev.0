From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] iov_iter: don't revert if csum error
Date: Fri, 28 Apr 2017 13:51:43 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFE1464@AcuExch.aculab.com>
References: <080dafec-c57f-0546-4d2f-ce4a31222e25@huawei.com>
 <20170428131631.GA22996@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
        "pabeni@redhat.com" <pabeni@redhat.com>,
        "edumazet@google.com" <edumazet@google.com>,
        "hannes@stressinduktion.org" <hannes@stressinduktion.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        LinuxArm <linuxarm@huawei.com>
To: 'Sabrina Dubroca' <sd@queasysnail.net>,
        Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.191]:53314 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933285AbdD1Nvy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 09:51:54 -0400
In-Reply-To: <20170428131631.GA22996@bistromath.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogU2FicmluYSBEdWJyb2NhDQo+IFNlbnQ6IDI4IEFwcmlsIDIwMTcgMTQ6MTcNCi4uLg0K
PiA+ICAJCWlmIChfX3NrYl9jaGVja3N1bV9jb21wbGV0ZShza2IpKQ0KPiA+IC0JCQlnb3RvIGNz
dW1fZXJyb3I7DQo+ID4gKwkJCWdvdG8gZmF1bHQ7DQo+IA0KPiBXaXRoIHRoaXMgcGF0Y2gsIHNr
Yl9jb3B5X2FuZF9jc3VtX2RhdGFncmFtX21zZygpIHdpbGwgcmV0dXJuIC1FRkFVTFQNCj4gZm9y
IGFuIGluY29ycmVjdCBjaGVja3N1bSwgdGhhdCBkb2Vzbid0IHNlZW0gcmlnaHQuDQoNCkVzcGVj
aWFsbHkgc2luY2UgKElJUkMpIC1FRkFVTFQgZ2VuZXJhdGVzIFNJR1NFR1YuDQoNCglEYXZpZA0K
DQo=
