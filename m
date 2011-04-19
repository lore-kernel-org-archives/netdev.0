From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix section mismatches
Date: Mon, 18 Apr 2011 22:59:16 -0700 (PDT)
Message-ID: <20110418.225916.183040104.davem@davemloft.net>
References: <20110418233120.E4B1F138DD@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	perex@perex.cz, samuel@sortiz.org, grundler@parisc-linux.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57562
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752397Ab1DSF7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 01:59:51 -0400
In-Reply-To: <20110418233120.E4B1F138DD@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 19 Apr 2011 01:31:20 +0200 (CEST)

> Fix build warnings like the following:
>=20
> WARNING: drivers/net/built-in.o(.data+0x12434): Section mismatch in r=
eference from the variable madgemc_driver to the variable .init.data:ma=
dgemc_adapter_ids
>=20
> And add some consts to EISA device ID tables along the way.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

I've applied this, thanks!
