From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: chelsio: convert to hw_features
Date: Mon, 18 Apr 2011 23:04:14 -0700 (PDT)
Message-ID: <20110418.230414.39170665.davem@davemloft.net>
References: <20110417101546.EE73713A67@rere.qmqm.pl>
	<20110418233120.CCB2313909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60210
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752269Ab1DSGEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 02:04:48 -0400
In-Reply-To: <20110418233120.CCB2313909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 19 Apr 2011 01:31:20 +0200 (CEST)

> Also remove flags that were not used or are now redundant to hw_featu=
res bits.
> No device had UDP_CSUM_CAPABLE set.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
> ---
> v2: fix usage of uninitialized variable in sge_rx()

Applied.
