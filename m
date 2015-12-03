From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: reset only targeted phy
Date: Thu, 03 Dec 2015 15:27:07 -0500 (EST)
Message-ID: <20151203.152707.1838297377209709950.davem@davemloft.net>
References: <1449133355-7668-1-git-send-email-jezz@sysmic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jezz@sysmic.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617AbbLCU1I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 15:27:08 -0500
In-Reply-To: <1449133355-7668-1-git-send-email-jezz@sysmic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: J=E9r=F4me Pouiller <jezz@sysmic.org>
Date: Thu,  3 Dec 2015 10:02:35 +0100

> It is possible to address another chip on same MDIO bus. The case is
> correctly handled for media advertising. It is taken into account
> only if mii_data->phy_id =3D=3D phydev->addr. However, this condition
> was missing for reset case.
>=20
> Signed-off-by: J=E9r=F4me Pouiller <jezz@sysmic.org>

Applied.
