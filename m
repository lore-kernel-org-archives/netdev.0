From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 2/6] sfc: Implement generic features
 interface
Date: Sun, 03 Apr 2011 21:27:31 +0100
Message-ID: <1301862451.2935.49.camel@localhost>
References: <1301859889.2935.23.camel@localhost>
	 <1301860281.2935.25.camel@localhost>  <20110403201322.GA13122@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12139 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114Ab1DCU1f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 16:27:35 -0400
In-Reply-To: <20110403201322.GA13122@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-04-03 at 22:13 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Sun, Apr 03, 2011 at 08:51:21PM +0100, Ben Hutchings wrote:
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> >  drivers/net/sfc/efx.c        |   17 ++++++++-
> >  drivers/net/sfc/ethtool.c    |   78 ------------------------------=
------------
> >  drivers/net/sfc/net_driver.h |    2 -
> >  drivers/net/sfc/rx.c         |    2 +-
> >  4 files changed, 16 insertions(+), 83 deletions(-)
> >=20
> [cut patch]
>=20
> Looks ok to me.
>=20
> BTW, I noticed that TSO6 is not enabled in vlan_features. Is this int=
entional?

Well spotted.  It's not intentional.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

