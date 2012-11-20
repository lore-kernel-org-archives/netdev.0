From: =?iso-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>
Subject: Re: unable to handle paging request, arm, at aio/tcp code, only 3.6
Date: Tue, 20 Nov 2012 22:26:32 +0100
Message-ID: <20121120212631.GF2186@vicerveza.homeunix.net>
References: <20121119183222.GI2068@vicerveza.homeunix.net>
 <1353354095.10798.76.camel@edumazet-glaptop>
 <1353360858.10798.86.camel@edumazet-glaptop>
 <20121120.151845.765619681074379121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-03-ewr.mailhop.org ([204.13.248.66]:31551 "EHLO
	mho-01-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753270Ab2KTV0i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 16:26:38 -0500
Content-Disposition: inline
In-Reply-To: <20121120.151845.765619681074379121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 20, 2012 at 03:18:45PM -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 19 Nov 2012 13:34:18 -0800
>=20
> > [PATCH] ipv6: fix inet6_csk_update_pmtu() return value
> >=20
> > In case of error, inet6_csk_update_pmtu() should consistently
> > return NULL.
> >=20
> > Bug added in commit 35ad9b9cf7d8a=20
> > (ipv6: Add helper inet6_csk_update_pmtu().)
> >=20
> > Reported-by: Llu=EDs Batlle i Rossell <viric@viric.name>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>=20
> My bad.  Applied and queued up for 3.6.x-stable, thanks!

All OK so far. No hang.

Thank you all!
