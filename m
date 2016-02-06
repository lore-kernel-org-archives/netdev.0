From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: add helper checking for BCM4707 / BCM53018 chip
 id
Date: Sat, 06 Feb 2016 03:37:38 -0500 (EST)
Message-ID: <20160206.033738.1878734951841887507.davem@davemloft.net>
References: <1454395634-11317-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hauke@hauke-m.de, nbd@openwrt.org
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbcBFIhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 03:37:42 -0500
In-Reply-To: <1454395634-11317-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Tue,  2 Feb 2016 07:47:14 +0100

> Chipsets with BCM4707 / BCM53018 ID require special handling at a few
> places in the code. It's likely there will be more IDs to check in th=
e
> future. To simplify it add this trivial helper.
>=20
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Applied.
