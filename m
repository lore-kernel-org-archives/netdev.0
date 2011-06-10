From: Petr =?iso-8859-2?Q?=A9tetiar?= <ynezz@true.cz>
Subject: Re: [PATCH v2 1/5] ep93xx: set DMA masks for the ep93xx_eth
Date: Fri, 10 Jun 2011 17:47:36 +0200
Message-ID: <20110610154736.GA16318@ibawizard.net>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi> <20110605083445.GT16318@ibawizard.net> <20110605085948.GB16018@acer>
Reply-To: Petr =?iso-8859-2?Q?=A9tetiar?= <ynezz@true.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Petr =?iso-8859-2?Q?=A9tetiar?= <ynezz@true.cz>,
	netdev@vger.kernel.org, kernel@wantstofly.org,
	hsweeten@visionengravers.com, ryan@bluewatersys.com,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Mika Westerberg <mika.westerberg@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ibawizard.net ([82.208.49.253]:37026 "EHLO
	mengele.ibawizard.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754382Ab1FJPrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 11:47:41 -0400
Content-Disposition: inline
In-Reply-To: <20110605085948.GB16018@acer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mika Westerberg <mika.westerberg@iki.fi> [2011-06-05 11:59:48]:

> On Sun, Jun 05, 2011 at 10:34:45AM +0200, Petr =A9tetiar wrote:
> >=20
> > do you have the series available somewhere for pull? I would like t=
o test the
> > changes for you on my ts7250/ts7300, but I'm quite lazy and would l=
ike to just
> > cherry-pick the changes if possible :-)
>=20
> Unfortunately - no. But what's wrong with 'git am <mbox>'? ;-)

I've tested the whole series and didn't find any problems so far, thank=
s. You
can add my

	Tested-by: Petr =A9tetiar <ynezz@true.cz>

if you wish.

-- ynezz
