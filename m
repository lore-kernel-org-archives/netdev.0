From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter/IPv6: initialize TOS field in REJECT target
 module
Date: Mon, 25 Apr 2011 22:17:30 -0700 (PDT)
Message-ID: <20110425.221730.193707936.davem@davemloft.net>
References: <1303459875.9791.19.camel@nausicaa>
	<1303461461.3134.15.camel@edumazet-laptop>
	<4DB61C2C.7060508@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, fernando@oss.ntt.co.jp,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, jengelh@medozas.de
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4DB61C2C.7060508@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 26 Apr 2011 03:13:16 +0200

> On 22/04/11 10:37, Eric Dumazet wrote:
>> Le vendredi 22 avril 2011 =E0 17:11 +0900, Fernando Luis Vazquez Cao=
 a
>> =E9crit :
>>=20
>>> Thank you!
>>>
>>> Should we send these two patches to -stable too?
>>=20
>> David takes care of stable submissions for netdev stuff, thanks.
>=20
> If the patch follows the netfilter path, we'll take care of sending
> stable submissions.

Right.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
