From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH net] net: fix ETHTOOL_SFEATURES compatibility
 with old ethtool_ops.set_flags
Date: Thu, 26 May 2011 14:14:11 -0400 (EDT)
Message-ID: <20110526.141411.2300557830076799104.davem@davemloft.net>
References: <20110524091437.GA10779@rere.qmqm.pl>
	<20110524.153930.610330240390616957.davem@davemloft.net>
	<7bcc407f555d2fbbcd66d26e4b0195060cf8c063.1306405895.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757810Ab1EZSOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 14:14:18 -0400
In-Reply-To: <7bcc407f555d2fbbcd66d26e4b0195060cf8c063.1306405895.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu, 26 May 2011 12:42:57 +0200 (CEST)

> Current code squashes flags to bool - this makes set_flags fail whene=
ver
> some ETH_FLAG_* equivalent features are set. Fix this.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
