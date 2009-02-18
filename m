From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/43] drivers/net/r6040.c: fix sparse warning: Using
 plain integer as NULL pointer
Date: Tue, 17 Feb 2009 17:22:16 -0800 (PST)
Message-ID: <20090217.172216.152466500.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214211400.23489.24726.stgit@vmbox.hanneseder.net>
	<200902151500.06516.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hannes@hanneseder.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47836
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755503AbZBRBWc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Feb 2009 20:22:32 -0500
In-Reply-To: <200902151500.06516.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Sun, 15 Feb 2009 15:00:06 +0100

> Hello Hannes,
>=20
> Le Saturday 14 February 2009 22:14:04 Hannes Eder, vous avez =E9crit=A0=
:
> > Fix this sparse warnings:
> >   drivers/net/r6040.c:487:31: warning: Using plain integer as NULL =
pointer
> >   drivers/net/r6040.c:492:31: warning: Using plain integer as NULL =
pointer
>=20
> Good catch, thanks.
> >
> > Signed-off-by: Hannes Eder <hannes@hanneseder.net>
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied.
