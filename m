From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Fixes for unified offload configuration
Date: Wed, 23 Feb 2011 14:24:27 -0800 (PST)
Message-ID: <20110223.142427.260100046.davem@davemloft.net>
References: <cover.1298429033.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42542
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932727Ab1BWWXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 17:23:50 -0500
In-Reply-To: <cover.1298429033.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Wed, 23 Feb 2011 03:52:28 +0100 (CET)

> this series contains couple of fixes to ethtool unification work in n=
et-next.
>=20
> patches 1 and 2 (resend):
> 	fix following message at device registration:
> 	(unregistered net_device): features changed: 0x00011065 -> 0x0001506=
5
>=20
> patches 3 and 4:
> 	implement compatibility fallback in ethtool_{g,s}features for driver=
s
> 	not converted to new offload setting scheme.
>=20
> only compile tested for now as my test box has some hardware issues l=
ately.

All applied, thanks.
