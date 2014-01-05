From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/5] bgmac: add initial support for core rev 4 on
 ARM BCM47xx
Date: Sat, 04 Jan 2014 20:26:11 -0500 (EST)
Message-ID: <20140104.202611.337362556459868464.davem@davemloft.net>
References: <1388880647-7611-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zajec5@gmail.com, netdev@vger.kernel.org
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbaAEB0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 20:26:13 -0500
In-Reply-To: <1388880647-7611-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Hauke Mehrtens <hauke@hauke-m.de>
Date: Sun,  5 Jan 2014 01:10:42 +0100

> This adds support for core rev 4 and ARM BCM47XX.
> With an other fix to the platform code I am now getting over 200 MBit=
/s=20
> with this Ethernet driver, the DMA problems are solved are unrelated
> to bgmac.
>=20
> v3:
>    - moved flags calculation for bcma_core_enable() into if block
>    - remove hard coding of phy address to BGMAC_PHY_NOREGS
>=20
> v2: add changed suggested by Rafa=A9=A9

Applied, thanks.
