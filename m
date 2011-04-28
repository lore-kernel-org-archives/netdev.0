From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: allow user to change NETIF_F_HIGHDMA
Date: Thu, 28 Apr 2011 13:33:24 -0700 (PDT)
Message-ID: <20110428.133324.28826133.davem@davemloft.net>
References: <20110422163116.37DE613909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55209
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750970Ab1D1Ud5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 16:33:57 -0400
In-Reply-To: <20110422163116.37DE613909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Fri, 22 Apr 2011 18:31:16 +0200 (CEST)

> NETIF_F_HIGHDMA is like any other TX offloads, so allow user to toggl=
e it.
> This is needed later for bridge and bonding convertsion to hw_feature=
s.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
