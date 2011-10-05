From: David Miller <davem@davemloft.net>
Subject: Re: netfilter: Use proper rwlock init function
Date: Wed, 05 Oct 2011 17:51:57 -0400 (EDT)
Message-ID: <20111005.175157.1216808653165374454.davem@davemloft.net>
References: <alpine.LFD.2.02.1110051522410.18778@ionos>
	<C8A6796DE7C66C4ABCBC18106CB6C1CC106D90314C@ESESSCMS0356.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tglx@linutronix.de, netdev@vger.kernel.org, ja@ssi.bg,
	horms@verge.net.au
To: hans.schillstrom@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934884Ab1JEVyU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 17:54:20 -0400
In-Reply-To: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D90314C@ESESSCMS0356.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Hans Schillstr=F6m <hans.schillstrom@ericsson.com>
Date: Wed, 5 Oct 2011 15:54:07 +0200

> Hello Simon,
> you can drop my "fix lockdep warning" patch
> since Thomas patch is identical to what I prepared to send...
>=20
>>Replace the open coded initialization with the init function.
>>
>>Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
>=20
> Ack-by: Hans Schillstrom <hans.schillstrom@ericsson.com>

[ It's "Acked-by" btw...]

Applied, thanks.
