From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter/IPv6:  initialize TOS field in REJECT target
 module
Date: Tue, 26 Apr 2011 03:13:16 +0200
Message-ID: <4DB61C2C.7060508@netfilter.org>
References: <1303455759.2023.39.camel@nausicaa>	 <1303456743.2023.55.camel@nausicaa>	 <1303457656.3134.12.camel@edumazet-laptop>	 <1303458454.9791.13.camel@nausicaa>	 <1303459560.3134.14.camel@edumazet-laptop>	 <1303459875.9791.19.camel@nausicaa> <1303461461.3134.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, jengelh@medozas.de, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1303461461.3134.15.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/04/11 10:37, Eric Dumazet wrote:
> Le vendredi 22 avril 2011 =C3=A0 17:11 +0900, Fernando Luis Vazquez C=
ao a
> =C3=A9crit :
>=20
>> Thank you!
>>
>> Should we send these two patches to -stable too?
>=20
> David takes care of stable submissions for netdev stuff, thanks.

If the patch follows the netfilter path, we'll take care of sending
stable submissions.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
