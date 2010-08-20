From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch nf-next] IPVS: convert __ip_vs_sched_lock to a spinlock
Date: Fri, 20 Aug 2010 16:56:28 +0200
Message-ID: <1282316188.2484.147.camel@edumazet-laptop>
References: <20100820145249.GB11781@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Changli Gao <xiaosuo@gmail.com>,
	yao zhao <dragonlinux@gmail.com>,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100820145249.GB11781@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 20 ao=C3=BBt 2010 =C3=A0 23:52 +0900, Simon Horman a =C3=A9=
crit :
> Also rename __ip_vs_sched_lock to ip_vs_sched_lock.
>=20
> Signed-off-by: Simon Horman <horms@verge.net.au>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
