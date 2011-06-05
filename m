From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: Re: [PATCH v2 1/5] ep93xx: set DMA masks for the ep93xx_eth
Date: Sun, 5 Jun 2011 11:59:48 +0300
Message-ID: <20110605085948.GB16018@acer>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
 <20110605083445.GT16318@ibawizard.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hsweeten@visionengravers.com,
	ryan@bluewatersys.com, kernel@wantstofly.org,
	linux-arm-kernel@lists.infradead.org, davem@davemloft.net
To: Petr =?utf-8?Q?=C5=A0tetiar?= <ynezz@true.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:64955 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853Ab1FEJCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 05:02:03 -0400
Received: by ewy4 with SMTP id 4so1067573ewy.19
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2011 02:02:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110605083445.GT16318@ibawizard.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 05, 2011 at 10:34:45AM +0200, Petr =C5=A0tetiar wrote:
>=20
> do you have the series available somewhere for pull? I would like to =
test the
> changes for you on my ts7250/ts7300, but I'm quite lazy and would lik=
e to just
> cherry-pick the changes if possible :-)

Unfortunately - no. But what's wrong with 'git am <mbox>'? ;-)

> I also wonder, why this patch[1] from Herbert Valerio Riedel has neve=
r made it
> upstream, this email[2] is the last trace of the patch I could find. =
Looks
> like Herbert did few fixes to the driver and thanks to Matthieu, I'm =
using
> this forward ported patch[3] since today, without any problems.

I have no idea.

It looks like David Miller (CC'd) has been taking care of ep93xx_eth.c =
maybe
he knows this better.

> Do you personaly use the ethernet on the ep93xx/ts72xx heavily?

Yes, I have NFS roots for the boards so it is essential for me.
