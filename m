From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv4 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Tue, 24 Dec 2013 10:50:07 +0100
Message-ID: <20131224095007.GA29716@secunet.com>
References: <1387424650.19078.355.camel@edumazet-glaptop2.roam.corp.google.com>
 <52B3BAD1.30205@windriver.com>
 <52B8DF80.2010508@windriver.com>
 <20131224.003125.1848179270970861998.davem@davemloft.net>
 <52B91E21.1050907@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51841 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486Ab3LXJuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Dec 2013 04:50:10 -0500
Content-Disposition: inline
In-Reply-To: <52B91E21.1050907@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 24, 2013 at 01:39:45PM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B412=E6=9C=8824=E6=97=A5 13:31, David Miller wrote:
> >From: Fan Du<fan.du@windriver.com>
> >Date: Tue, 24 Dec 2013 09:12:32 +0800
> >
> >>>  I saw this patch is marked 'Not Applicable' in patchwork.
> >It means that it doesn't go in via my tree directly, it
> >"doesn't apply".
> >
> >Instead, it goes into Steffen's IPSEC tree.
> >

Yes, I'll take care about this one. I'm currently traveling,
so I have not that much time for review and tests of patches.
I'll integrate all pending ipsec patches after the holidays.

>=20
> Thanks for your explanation!!!
>=20
> I'm not well understand the curtsy about patchwork, and one last ques=
tion,
> [PATCHv4 net-next 0/8] pktgen IPsec support is tagged as 'Awaiting Up=
stream'
> what does that mean and do I need to take further action about this p=
atch set?
>=20

I guess that means the same, it goes into the ipsec-next tree :)
