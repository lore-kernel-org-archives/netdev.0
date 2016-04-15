From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4.6 fix] bgmac: fix MAC soft-reset bit for corerev > 4
Date: Thu, 14 Apr 2016 21:17:43 -0400 (EDT)
Message-ID: <20160414.211743.968358101075476198.davem@davemloft.net>
References: <1460478449-22561-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hauke@hauke-m.de, nbd@openwrt.org
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbcDOBRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 21:17:45 -0400
In-Reply-To: <1460478449-22561-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Tue, 12 Apr 2016 18:27:29 +0200

> From: Felix Fietkau <nbd@openwrt.org>
>=20
> Only core revisions older than 4 use BGMAC_CMDCFG_SR_REV0. This mainl=
y
> fixes support for BCM4708A0KF SoCs with Ethernet core rev 5 (it means
> only some devices as most of BCM4708A0KF-s got core rev 4).
> This was tested for regressions on BCM47094 which doesn't seem to car=
e
> which bit gets used.
>=20
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Applied.
