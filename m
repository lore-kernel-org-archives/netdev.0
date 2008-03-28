From: David Miller <davem@davemloft.net>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Fri, 28 Mar 2008 16:21:37 -0700 (PDT)
Message-ID: <20080328.162137.132976647.davem@davemloft.net>
References: <20080328132359.15573601@speedy>
	<20080328203358.M8487@visp.net.lb>
	<47ED6066.2010407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: denys@visp.net.lb, stephen.hemminger@vyatta.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35759
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755571AbYC1XVi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 19:21:38 -0400
In-Reply-To: <47ED6066.2010407@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 28 Mar 2008 22:17:26 +0100

> Denys Fedoryshchenko a =E9crit :
> > It seems or patch change something (but it is just showing debug, s=
trange),=20
> > or there is something fixed between 2.6.25-rc7-git1 and 2.6.25-rc7-=
git3. LC-
> > trie working fine, HASH also i cannot see any leaks.
>=20
> Yes, the fix is the patch we mentioned yesterday, and you told us you=
 tried it :(

Denys please be more careful in the future :-(

So much time and effort got wasted because of this.
