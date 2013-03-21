From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] fec: Unify fec_ptp.c and fec.c
Date: Thu, 21 Mar 2013 11:31:57 +0100
Message-ID: <20130321103157.GP20530@pengutronix.de>
References: <1363810268-24398-1-git-send-email-festevam@gmail.com>
 <20130321062146.GL20530@pengutronix.de>
 <CAHrpEqTd2mVaTW6pwJaHqYreDo6rT_6s_o=Z=OtU71PZzZCSVg@mail.gmail.com>
 <20130321100949.GO20530@pengutronix.de>
 <CAHrpEqSKS66EK_0L-e3=kDGAAYH3uBKzs=4pkmzvrJoVZpBgyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fabio Estevam <festevam@gmail.com>, davem@davemloft.net,
	Frank.Li@freescale.com, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50044 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703Ab3CUKcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 06:32:02 -0400
Content-Disposition: inline
In-Reply-To: <CAHrpEqSKS66EK_0L-e3=kDGAAYH3uBKzs=4pkmzvrJoVZpBgyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Frank,

On Thu, Mar 21, 2013 at 06:15:28PM +0800, Frank Li wrote:
> 2013/3/21 Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>:
> > What is missing from your patch is dropping the EXPORT_SYMBOLs. Oth=
er
> > than that I like it better than using a single .c file.
>=20
> There are not EXPORT_SYMBOL in my fec.c? which version do you use?
As David said he took Fabio's patch for stable I assume they are in
net-next. I didn't check though.

Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
