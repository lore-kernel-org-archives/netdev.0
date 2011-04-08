From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: benet: convert to hw_features
Date: Thu, 07 Apr 2011 20:18:12 -0700 (PDT)
Message-ID: <20110407.201812.104054489.davem@davemloft.net>
References: <20110407124348.A8F1E13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50703
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757358Ab1DHDSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 23:18:48 -0400
In-Reply-To: <20110407124348.A8F1E13909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu,  7 Apr 2011 14:43:48 +0200 (CEST)

> Simple conversion.
>=20
> This also fixes a bug in TX checksum toggling --- driver was changing
> NETIF_F_HW_CSUM instead of NETIF_F_IP_CSUM+NETIF_F_IPV6_CSUM.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
