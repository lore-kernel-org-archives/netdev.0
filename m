From: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH 2/2] net: Export IGMP/MLD message validation code
Date: Mon, 13 Apr 2015 16:18:00 +0900
Message-ID: <552B6DA8.10500@miraclelinux.com>
References: <1428687999-18428-1-git-send-email-linus.luessing@c0d3.blue> <1428687999-18428-2-git-send-email-linus.luessing@c0d3.blue> <20150411014645.GA20155@odroid>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hideaki.yoshifuji@miraclelinux.com
To: =?UTF-8?B?TGludXMgTMO8c3Npbmc=?= <linus.luessing@c0d3.blue>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150411014645.GA20155@odroid>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus L=C3=BCssing wrote:
> On Fri, Apr 10, 2015 at 07:46:39PM +0200, Linus L=C3=BCssing wrote:
>> diff --git a/net/ipv6/mcast_snoop.c b/net/ipv6/mcast_snoop.c
>> new file mode 100644
>> index 0000000..95b34c0
>> --- /dev/null
>> +++ b/net/ipv6/mcast_snoop.c
>> @@ -0,0 +1,198 @@
>> +/* Copyright (C) 2015: Linus L=C3=BCssing <linus.luessing@c0d3.blue=
>
>=20
> PS: I'm a little uncertain how this is usually done. If I should
> add someone (maybe Hideaki YOSHIFUJI, the original author of the
> bridge IPv6/MLD support?), then please let me know.

If you want to claim copyright, add myself (2010,
yoshfuji@linux-ipv6.org).  You may have Authors: lines for both.
Also, you could have description like "Based on MLD support by
=2E..".

--yoshfuji
