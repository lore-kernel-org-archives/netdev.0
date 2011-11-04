From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/9] Cleanup and extension of netdev features
Date: Thu, 03 Nov 2011 22:46:28 -0400 (EDT)
Message-ID: <20111103.224628.524941091808899845.davem@davemloft.net>
References: <cover.1319495301.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60770 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236Ab1KDCrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 22:47:36 -0400
In-Reply-To: <cover.1319495301.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 25 Oct 2011 02:36:33 +0200 (CEST)

> Commit fd38f734 (igbvf: convert to ndo_fix_features) removed last use
> of old ethtool ops for controlling netdevice's features. This series
> finishes the cleanup and extends feature pool to 64 bits.
>=20
> Also, there's additional patch that removes NETIF_F_NO_CSUM as it is
> now, and has been for some time, equivalent to NETIF_F_HW_CSUM.
>=20
> To see the new features in action, you need ethtool patched with:
>=20
> http://patchwork.ozlabs.org/patch/96374/
>=20
> Not much has changed in those patches compared to last version I post=
ed
> in June.
>=20
> Compile tested whole series only. I'll do more thorough testing next
> week after I prepare new testing machine.

Sorry this just missed the merge window.

Please submit this again once the net-next tree opens back up.

Thanks!
