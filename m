From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-rhine: fix full-duplex with autoneg disable
Date: Thu, 12 Jun 2014 10:32:03 -0700 (PDT)
Message-ID: <20140612.103203.1223568534065505346.davem@davemloft.net>
References: <53997CCD.4010200@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rl@hellgate.ch, netdev@vger.kernel.org
To: f.cachereul@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116AbaFLRcE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 13:32:04 -0400
In-Reply-To: <53997CCD.4010200@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fran=E7ois Cachereul <f.cachereul@alphalink.fr>
Date: Thu, 12 Jun 2014 12:11:25 +0200

> With some specific configuration (VT6105M on Soekris 5510 and dependi=
ng
> on the device at the other end), fragmented packets were not transmit=
ted
> when forcing 100 full-duplex with autoneg disable.
>=20
> This fix now write full-duplex chips register when forcing full or
> half-duplex not only when autoneg is enable.
>=20
> Signed-off-by: Fran=E7ois Cachereul <f.cachereul@alphalink.fr>

Applied.
