From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter/IPv6: initialize TOS field in REJECT target
 module
Date: Mon, 25 Apr 2011 22:17:44 -0700 (PDT)
Message-ID: <20110425.221744.226775617.davem@davemloft.net>
References: <1303461461.3134.15.camel@edumazet-laptop>
	<4DB61C2C.7060508@netfilter.org>
	<1303781180.2874.13.camel@nausicaa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pablo@netfilter.org, eric.dumazet@gmail.com,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, jengelh@medozas.de
To: fernando@oss.ntt.co.jp
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1303781180.2874.13.camel@nausicaa>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Date: Tue, 26 Apr 2011 10:26:20 +0900

> On Tue, 2011-04-26 at 03:13 +0200, Pablo Neira Ayuso wrote:
>> On 22/04/11 10:37, Eric Dumazet wrote:
>> > Le vendredi 22 avril 2011 =E0 17:11 +0900, Fernando Luis Vazquez C=
ao a
>> > =E9crit :
>> >=20
>> >> Thank you!
>> >>
>> >> Should we send these two patches to -stable too?
>> >=20
>> > David takes care of stable submissions for netdev stuff, thanks.
>>=20
>> If the patch follows the netfilter path, we'll take care of sending
>> stable submissions.
>=20
> David, will you take care of these two patches or should they go thro=
ugh
> the netfilter tree?

Netfilter, as usual.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
