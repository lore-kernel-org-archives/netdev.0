From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] bgmac: fix "cmdcfg" calls for promisc and loopback
 modes
Date: Fri, 08 Feb 2013 17:44:12 -0500 (EST)
Message-ID: <20130208.174412.315468738266815908.davem@davemloft.net>
References: <1360232591-25789-1-git-send-email-zajec5@gmail.com>
	<1360251638-20925-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, nlhintz@hotmail.com
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37993 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760362Ab3BHWoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 17:44:13 -0500
In-Reply-To: <1360251638-20925-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Thu,  7 Feb 2013 16:40:38 +0100

> The last (bool) parameter in bgmac_cmdcfg_maskset says if the write
> should be made, even if value didn't change. Currently driver doesn't
> match the specs about (not) forcing some changes. This makes it follo=
w
> them.
>=20
> Reported-by: Nathan Hintz <nlhintz@hotmail.com>
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Applied.
