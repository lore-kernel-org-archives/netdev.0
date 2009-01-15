From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] korina: reset resource buffer size to 1536
Date: Wed, 14 Jan 2009 21:47:58 -0800 (PST)
Message-ID: <20090114.214758.117490007.davem@davemloft.net>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org>
	<200901141857.50984.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: n0-1@freewrt.org, netdev@vger.kernel.org, jeff@garzik.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47679
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754309AbZAOFr5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 00:47:57 -0500
In-Reply-To: <200901141857.50984.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Wed, 14 Jan 2009 18:57:50 +0100

> Le Wednesday 14 January 2009 18:50:00 Phil Sutter, vous avez =E9crit=A0=
:
> > The new value is the one used in the external patch before and allo=
ws at
> > least a standard MTU of 1500 to be handled correctly. Impact of thi=
s
> >
> > change gets visible when bigger packets are to be received, issuing=
:
> > | ping -s 492 <IP>
> >
> > and bigger payload sized led to 100% packet loss.
>=20
> Thanks
>=20
> >
> > Signed-off-by: Phil Sutter <n0-1@freewrt.org>
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org

Applied.
