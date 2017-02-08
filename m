From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: KASAN+netlink, was: [PATCH] [net-next?] hns: avoid stack
 overflow with CONFIG_KASAN
Date: Wed, 8 Feb 2017 16:00:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB027F2B4@AcuExch.aculab.com>
References: <20170203163607.3488037-1-arnd@arndb.de>
         <20170206.120318.1268240226202516488.davem@davemloft.net>
         <4910112.l20yySyWnA@wuerfel> (sfid-20170208_130733_449950_64BEF84C)
 <1486556665.24745.6.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "stable@vger.kernel.org" <stable@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Andrey Ryabinin" <a.ryabinin@samsung.com>,
        "nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
        "nicolas.dichtel@6wind.com" <nicolas.dichtel@6wind.com>,
        "adobriyan@gmail.com" <adobriyan@gmail.com>,
        linux-wireless <linux-wireless@vger.kernel.org>
To: 'Johannes Berg' <johannes@sipsolutions.net>,
        Arnd Bergmann <arnd@arndb.de>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486556665.24745.6.camel@sipsolutions.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiBGcm9tOiBKb2hhbm5lcyBCZXJnDQo+IFNlbnQ6IDA4IEZlYnJ1YXJ5IDIwMTcgMTI6MjQNCi4u
Lg0KPiBCdHcsIHdoYXQncyBjYXVzaW5nIHRoaXMgdG8gc3RhcnQgd2l0aD8gQ2FuJ3QgdGhlIGNv
bXBpbGVyIHJldXNlIHRoZQ0KPiBzdGFjayBwbGFjZXM/DQoNCk9ubHkgaWYgaXQgcmVhbGlzZXMg
dGhleSd2ZSBnb25lIG91dCBvZiBzY29wZSAtIHdoaWNoIHByb2JhYmx5DQpkb2Vzbid0IGhhcHBl
biB3aGVuIHRoZSBmdW5jdGlvbnMgYXJlIGlubGluZWQuDQpUaGUgYWRkcmVzcyBvZiB0aGUgcGFy
YW1ldGVyIGNhbiBiZSBzYXZlZCBieSB0aGUgY2FsbGluZyBmdW5jdGlvbg0KYW5kIHVzZWQgaW4g
YSBsYXRlciBjYWxsLg0KDQpTb21ldGhpbmcgbGlrZSB0aGlzIGlzIHZhbGlkOg0KDQppbnQgZm9v
KGludCAqcCwgaW50IHYpDQp7DQoJc3RhdGljIGludCAqc3Y7DQoJaW50IG9sZCA9IC0xOw0KCWlm
IChzdikge29sZCA9ICpzdjsgKnN2ID0gdjt9DQoJc3YgPSB2Ow0KCXJldHVybiBvbGQ7DQp9DQoN
CnZvaWQgYmFyKC4uLikgew0KCWludCBhLCBiOw0KCS4uLg0KCWZvbygmYSwgMCk7DQoJLi4uDQoJ
Zm9vKCZiLCAxKTsNCgkuLi4NCglmb28oTlVMTCwgMik7DQoJLi4uDQoNCklmIHRoZSBjb21waWxl
ciBzdGFydHMgc2hhcmluZyBzdGFjayBpdCBhbGwgZ29lcyB3cm9uZy4NCg0KCURhdmlkDQoNCg0K
