From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix netdev_increment_features()
Date: Thu, 28 Apr 2011 13:33:31 -0700 (PDT)
Message-ID: <20110428.133331.102537690.davem@davemloft.net>
References: <20110422163116.3C5C3138DD@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	fubar@us.ibm.com, andy@greyhouse.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55215
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932102Ab1D1UeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 16:34:04 -0400
In-Reply-To: <20110422163116.3C5C3138DD@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Fri, 22 Apr 2011 18:31:16 +0200 (CEST)

> Simplify and fix netdev_increment_features() to conform to what is
> stated in netdevice.h comments about NETIF_F_ONE_FOR_ALL.
> Include FCoE segmentation and VLAN-challedged flags in computation.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
