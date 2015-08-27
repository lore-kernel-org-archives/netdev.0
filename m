From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: support up to 3 cores (devices) on a bus
Date: Thu, 27 Aug 2015 11:29:04 -0700 (PDT)
Message-ID: <20150827.112904.2273619490566561555.davem@davemloft.net>
References: <1440604425-11094-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hauke@hauke-m.de
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45573 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbbH0S3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 14:29:05 -0400
In-Reply-To: <1440604425-11094-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Wed, 26 Aug 2015 17:53:45 +0200

> Broadcom buses may have more than 1 Ethernet device. This is used e.g=
=2E
> to have few interfaces connected to different switch ports. So far we
> saw chipsets with only 2 devices (e.g. BCM4706) but recent ones have
> up to 3 (e.g. Netgear R8000 uses 3rd interface for most of switch
> traffic, lower interfaces are for some kind of offloading).
>=20
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Applied to net-next, thanks.
