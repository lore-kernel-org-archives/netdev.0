From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] netfilter: fix the hash random initializing race
Date: Fri, 20 Aug 2010 18:35:55 +0200
Message-ID: <1282322155.2484.309.camel@edumazet-laptop>
References: <1282320404-2948-1-git-send-email-xiaosuo@gmail.com>
	 <1282321023.2484.285.camel@edumazet-laptop>
	 <alpine.LSU.2.01.1008201819080.7497@obet.zrqbmnf.qr>
	 <1282321600.2484.297.camel@edumazet-laptop>
	 <alpine.LSU.2.01.1008201832500.7497@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1008201832500.7497@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 20 ao=C3=BBt 2010 =C3=A0 18:34 +0200, Jan Engelhardt a =C3=A9=
crit :
> On Friday 2010-08-20 18:26, Eric Dumazet wrote:
>=20
> >> Actually,
> >> 	/*
> >> 	 * Some
> >> 	 */
> >> But that's in CodingStyle already. Always a good read, even if rer=
ead.
> >
> >Sorry, I documented David S. Miller choice, or else I would have
> >mentioned CodingStyle :)
> >
> >	/* Some
> >	 * fine
> >	 * comment
> >	 */
> >
> >And it really is better ;)
>=20
> Looks unsymmetric, which is probably the reason CodingStyle was=20
> conceived differently in the first place.

Who said comments must be symmetric ? :)

http://www.spinics.net/lists/netdev/msg134727.html



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
