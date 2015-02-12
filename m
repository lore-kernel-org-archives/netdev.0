From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH FIX] bgmac: fix device initialization on Northstar SoCs
 (condition typo)
Date: Wed, 11 Feb 2015 19:44:40 -0800 (PST)
Message-ID: <20150211.194440.1727636577062786321.davem@davemloft.net>
References: <1423674394-8578-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hauke@hauke-m.de
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932325AbbBLDhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 22:37:38 -0500
In-Reply-To: <1423674394-8578-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Wed, 11 Feb 2015 18:06:34 +0100

> On Northstar (Broadcom's ARM architecture) we need to manually enable
> all cores. Code for that is already in place, but the condition for i=
t
> was wrong.
>=20
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Applied.
