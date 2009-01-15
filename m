From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] korina: disable napi on close and restart
Date: Wed, 14 Jan 2009 21:48:30 -0800 (PST)
Message-ID: <20090114.214830.255386797.davem@davemloft.net>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org>
	<1231955448-10877-1-git-send-email-n0-1@freewrt.org>
	<200901141858.25530.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: n0-1@freewrt.org, netdev@vger.kernel.org, jeff@garzik.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47685
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751382AbZAOFs3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 00:48:29 -0500
In-Reply-To: <200901141858.25530.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Wed, 14 Jan 2009 18:58:25 +0100

> Le Wednesday 14 January 2009 18:50:48 Phil Sutter, vous avez =E9crit=A0=
:
> > Without this the driver will crash when the NIC is being restarted.
> >
> > Signed-off-by: Phil Sutter <n0-1@freewrt.org>
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied.
