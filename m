From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] korina: do not stop queue here
Date: Wed, 14 Jan 2009 21:51:23 -0800 (PST)
Message-ID: <20090114.215123.165020844.davem@davemloft.net>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org>
	<1231955526-12600-1-git-send-email-n0-1@freewrt.org>
	<200901141900.39137.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: n0-1@freewrt.org, netdev@vger.kernel.org, jeff@garzik.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47712
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754253AbZAOFvV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 00:51:21 -0500
In-Reply-To: <200901141900.39137.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Wed, 14 Jan 2009 19:00:38 +0100

> Le Wednesday 14 January 2009 18:52:06 Phil Sutter, vous avez =E9crit=A0=
:
> > Apparently this doesn't make sense. Otherwise the queue gets disabl=
ed as
> > soon as it's getting empty and can only be resurrected by a driver
> > restart.
> >
> > Signed-off-by: Phil Sutter <n0-1@freewrt.org>
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied.
