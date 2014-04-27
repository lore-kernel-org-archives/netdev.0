From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] arc_emac: add clock handling
Date: Sun, 27 Apr 2014 19:54:23 -0400 (EDT)
Message-ID: <20140427.195423.788429574120983614.davem@davemloft.net>
References: <1712306.TSJMmGq3uZ@phil>
	<5262035.54Ti8h2BVg@phil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey.Brodkin@synopsys.com, netdev@vger.kernel.org,
	max.schwarz@online.de, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org
To: heiko@sntech.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35352 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbaD0XyZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 19:54:25 -0400
In-Reply-To: <5262035.54Ti8h2BVg@phil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Heiko St=FCbner <heiko@sntech.de>
Date: Fri, 25 Apr 2014 10:06:13 +0200

> This adds ability for the arc_emac to really handle its supplying clo=
ck.
> To get the needed clock-frequency either a real clock or the previous
> clock-frequency property must be provided.
>=20
> Signed-off-by: Heiko Stuebner <heiko@sntech.de>
> Tested-by: Max Schwarz <max.schwarz@online.de>

Applied.
