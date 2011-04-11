From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] Gemini: Gigabit ethernet driver
Date: Mon, 11 Apr 2011 13:38:24 -0700 (PDT)
Message-ID: <20110411.133824.15228672.davem@davemloft.net>
References: <20110410160501.72EB213909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ulli.kroll@googlemail.com, gemini-board-dev@lists.berlios.de,
	netdev@vger.kernel.org, linux-kernel.bfrz@manchmal.in-ulm.de
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37195
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753756Ab1DKUjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 16:39:00 -0400
In-Reply-To: <20110410160501.72EB213909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sun, 10 Apr 2011 18:05:01 +0200 (CEST)

> In-Reply-To: <20110126232419.4794513909@rere.qmqm.pl>
>=20
> Driver for SL351x (Gemini) SoC ethernet peripheral. Based in part
> on work by Paulius Zaleckas and GPLd code from Raidsonic and other
> NAS vendors.
>=20
> Tested on Raidsonic IcyBox 4220-B (dual SATA NAS).
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

I'm pretty much fine with the networking parts:

Acked-by: David S. Miller <davem@davemloft.net>

but there are so many ARM, RTC, etc. pieces in here that I'd
like to ask you to push this through whatever ARM tree is
appropriate.

Thanks.
