From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ksz884x: convert to hw_features
Date: Sun, 10 Apr 2011 18:56:40 -0700 (PDT)
Message-ID: <20110410.185640.179939712.davem@davemloft.net>
References: <20110410131321.BE47D13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Tristram.Ha@micrel.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42691
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753802Ab1DKB5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2011 21:57:16 -0400
In-Reply-To: <20110410131321.BE47D13909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sun, 10 Apr 2011 15:13:21 +0200 (CEST)

> This also fixes possible race when changing receive checksum state
> and removes IPV6_CSUM_GEN_HACK as it's always set.
>=20
> BTW, The claim about fake IPV6 checksum looks dubious. If that were t=
rue,
> then there's a problem in networking core and should be fixed there a=
nd not
> in random drivers.
>=20
> BTW#2, there's no MAINTAINERS entry for this driver. I assume this dr=
iver
> is supported by Micrel?
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
