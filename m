From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3] bgmac: validate (and random if needed) MAC addr
Date: Fri, 08 Feb 2013 17:42:54 -0500 (EST)
Message-ID: <20130208.174254.1263035582813088511.davem@davemloft.net>
References: <1360232078-21872-1-git-send-email-zajec5@gmail.com>
	<1360232837-29696-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, florian@openwrt.org
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760366Ab3BHWmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 17:42:55 -0500
In-Reply-To: <1360232837-29696-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Thu,  7 Feb 2013 11:27:17 +0100

> This adds check for a valid Ethernet MAC address and in case it is no=
t,
> it will generate a valid random one, such that the adapter is still
> usable.
>=20
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Applied, thanks.
