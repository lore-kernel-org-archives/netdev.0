From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ks8842: Add platform data for setting mac address
Date: Wed, 21 Apr 2010 16:33:39 -0700 (PDT)
Message-ID: <20100421.163339.203286667.davem@davemloft.net>
References: <1271628741.18194.7.camel@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: richard.rojfors@pelagicore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55466
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754892Ab0DUXdf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 19:33:35 -0400
In-Reply-To: <1271628741.18194.7.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Richard R=F6jfors <richard.rojfors@pelagicore.com>
Date: Mon, 19 Apr 2010 00:12:21 +0200

> This patch adds platform data to the ks8842 driver.
>=20
> Via the platform data a MAC address, to be used by the controller,
> can be passed.
>=20
> To ensure this MAC address is used, the MAC address is written
> after each hardware reset.
>=20
> Signed-off-by: Richard R=F6jfors <richard.rojfors@pelagicore.com>

Applied to net-next-2.6, thanks Richard.
