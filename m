From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Tulip: don't initialize SBE xT3E3 WAN ports.
Date: Mon, 02 Aug 2010 16:03:42 -0700 (PDT)
Message-ID: <20100802.160342.57469958.davem@davemloft.net>
References: <m31vakc7yb.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47721
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751550Ab0HBXDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:03:23 -0400
In-Reply-To: <m31vakc7yb.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sat, 31 Jul 2010 11:32:44 +0200

> SBE 2T3E3 cards use DECchips 21143 but they need a different driver.
> Don't even try to use a normal tulip driver with them.
>=20
> Signed-off-by: Krzysztof Ha=A9=A9asa <khc@pm.waw.pl>

Applied, thanks.
