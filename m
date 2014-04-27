From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] arc_emac: fix probe error path
Date: Sun, 27 Apr 2014 19:54:18 -0400 (EDT)
Message-ID: <20140427.195418.748040758206627809.davem@davemloft.net>
References: <1712306.TSJMmGq3uZ@phil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey.Brodkin@synopsys.com, netdev@vger.kernel.org,
	max.schwarz@online.de, linux-kernel@vger.kernel.org
To: heiko@sntech.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbaD0XyU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 19:54:20 -0400
In-Reply-To: <1712306.TSJMmGq3uZ@phil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Heiko St=FCbner <heiko@sntech.de>
Date: Fri, 25 Apr 2014 10:03:29 +0200

> The probe function at the moment only frees the netdev but does not d=
isconnect
> the phy or removes the mdio bus it registered.
>=20
> Signed-off-by: Heiko Stuebner <heiko@sntech.de>

Applied.
