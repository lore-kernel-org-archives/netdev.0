From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: return error on failed PHY write
Date: Wed, 13 Feb 2013 13:58:43 -0500 (EST)
Message-ID: <20130213.135843.595990597648635704.davem@davemloft.net>
References: <1360746891-15124-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756382Ab3BMS6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 13:58:45 -0500
In-Reply-To: <1360746891-15124-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Wed, 13 Feb 2013 10:14:51 +0100

> Some callers may want to know if PHY write succeed. Also make PHY
> functions static, they are not exported anywhere.
>=20
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Applied, thanks.
