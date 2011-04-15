From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: forcedeth: convert to hw_features
Date: Fri, 15 Apr 2011 15:51:28 -0700 (PDT)
Message-ID: <20110415.155128.15248997.davem@davemloft.net>
References: <20110415145049.CC33613A65@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59741
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751187Ab1DOWwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 18:52:03 -0400
In-Reply-To: <20110415145049.CC33613A65@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Fri, 15 Apr 2011 16:50:49 +0200 (CEST)

> This also fixes a race around np->txrxctl_bits while changing RXCSUM =
offload.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
