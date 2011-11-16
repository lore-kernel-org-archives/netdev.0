From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v5 2/9] net: ethtool: break association of ETH_FLAG_*
 with NETIF_F_*
Date: Wed, 16 Nov 2011 02:06:45 +0000
Message-ID: <1321409205.2744.36.camel@bwh-desktop>
References: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
	 <768d41024675f5dd2ca20e77e2f04cc7a8aa0519.1321404954.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:57035 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932925Ab1KPCGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 21:06:49 -0500
In-Reply-To: <768d41024675f5dd2ca20e77e2f04cc7a8aa0519.1321404954.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-16 at 02:29 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> This is the only place left where dev->features are directly
> exposed to userspace.
>=20
> I know checkpatch.pl complains about __ethtool_{get,set}_flags(), but
> the code is easier to read this way.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
