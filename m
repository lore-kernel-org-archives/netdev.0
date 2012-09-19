From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: provide a default dev->ethtool_ops
Date: Wed, 19 Sep 2012 15:41:17 -0400 (EDT)
Message-ID: <20120919.154117.447250069349028510.davem@davemloft.net>
References: <1347607441.8555.265.camel@edumazet-glaptop>
	<1347716447.13258.101.camel@deadeye.wl.decadent.org.uk>
	<1347823046.26523.44.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org, maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56772 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254Ab2ISTlU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 15:41:20 -0400
In-Reply-To: <1347823046.26523.44.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 16 Sep 2012 21:17:26 +0200

> From: Eric Dumazet <edumazet@google.com>
 ...
> [PATCH v2 net-next] net: provide a default dev->ethtool_ops
>=20
> Instead of forcing device drivers to provide empty ethtool_ops or twe=
ak
> net/core/ethtool.c again, we could provide a generic ethtool_ops.
>=20
> This occurred to me when I wanted to add GSO support to GRE tunnels.
> ethtool -k support should be generic for all drivers.
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> Cc: Maciej =AFenczykowski <maze@google.com>

Great work, applied, thanks Eric.
