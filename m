From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] korina: drop leftover assignment
Date: Mon, 19 Jan 2009 16:23:35 -0800 (PST)
Message-ID: <20090119.162335.217248337.davem@davemloft.net>
References: <1232058598-15811-2-git-send-email-n0-1@freewrt.org>
	<20090115223008.B784E4043837@mail.nwl.cc>
	<200901192207.02031.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: n0-1@freewrt.org, netdev@vger.kernel.org, jeff@garzik.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49537
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762104AbZATAXd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 19:23:33 -0500
In-Reply-To: <200901192207.02031.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Mon, 19 Jan 2009 22:07:01 +0100

> Le Thursday 15 January 2009 23:29:57 Phil Sutter, vous avez =E9crit=A0=
:
> > As the assigned value is being overwritten shortly after, it can be
> > dropped and so the whole variable definition moved to the start of =
the
> > function.
> >
> > Signed-off-by: Phil Sutter <n0-1@freewrt.org>
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied.
