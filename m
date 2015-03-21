From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bgmac: register fixed PHY for ARM BCM470X /
 BCM5301X chipsets
Date: Fri, 20 Mar 2015 21:45:17 -0400 (EDT)
Message-ID: <20150320.214517.2203024451897882941.davem@davemloft.net>
References: <1426889672-4969-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hauke@hauke-m.de
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978AbbCUBpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 21:45:19 -0400
In-Reply-To: <1426889672-4969-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Fri, 20 Mar 2015 23:14:31 +0100

> On ARM SoCs with bgmac Ethernet hardware we don't have any normal PHY=
=2E
> There is always a switch attached but it's not even controlled over M=
DIO
> like in case of MIPS devices.
> We need a fixed PHY to be able to send/receive packets from the switc=
h.
>=20
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Applied to net-next.
