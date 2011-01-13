From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] netfilter: ipt_CLUSTERIP: remove "no conntrack!"
Date: Thu, 13 Jan 2011 17:48:49 +0100
Message-ID: <1294937329.3570.304.camel@edumazet-laptop>
References: <4D2E1A74.5080102@netfilter.org>
	 <1294917210.3570.48.camel@edumazet-laptop> <4D2EE09A.1010409@netfilter.org>
	 <1294918365.3570.56.camel@edumazet-laptop> <4D2EE80B.6010707@netfilter.org>
	 <1294925915.3570.87.camel@edumazet-laptop>
	 <alpine.LNX.2.01.1101131502240.25211@obet.zrqbmnf.qr>
	 <1294929579.3570.163.camel@edumazet-laptop> <4D2F28B9.50407@netfilter.org>
	 <4D2F29D6.3040600@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D2F29D6.3040600@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 13 janvier 2011 =C3=A0 17:35 +0100, Pablo Neira Ayuso a =C3=A9=
crit :
> On 13/01/11 17:30, Pablo Neira Ayuso wrote:
> > On 13/01/11 15:39, Eric Dumazet wrote:
> >> Then, cluster match can be improved, I am sure you already have a =
patch
> >> for it.
> >=20
> > what scenario could benefit from the destination-based hashing?
>=20
> I'm telling this because it doesn't make too sense to me.

Me too ;)

But hash(source_IP, source_PORT) definitely make sense in some
workloads.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
