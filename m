From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Remove invalid offloads
Date: Sun, 10 Apr 2011 18:55:42 -0700 (PDT)
Message-ID: <20110410.185542.115938862.davem@davemloft.net>
References: <20110408123846.D947E13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pantelis.antoniou@gmail.com,
	vbordug@ru.mvista.com, leoli@freescale.com,
	linuxppc-dev@lists.ozlabs.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42658
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752912Ab1DKB4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2011 21:56:18 -0400
In-Reply-To: <20110408123846.D947E13909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Fri,  8 Apr 2011 14:38:46 +0200 (CEST)

> Remove offload changing ethtool ops which drivers don't really suppor=
t:
>=20
>  - fs_enet
>  - ucc_geth
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
