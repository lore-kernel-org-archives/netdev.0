From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: enic: convert to hw_features
Date: Thu, 07 Apr 2011 20:18:06 -0700 (PDT)
Message-ID: <20110407.201806.71112752.davem@davemloft.net>
References: <20110407124348.BB13A138ED@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, benve@cisco.com, vkolluri@cisco.com,
	roprabhu@cisco.com, dwang2@cisco.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50698
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757358Ab1DHDSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 23:18:42 -0400
In-Reply-To: <20110407124348.BB13A138ED@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu,  7 Apr 2011 14:43:48 +0200 (CEST)

> As the driver uses GRO and not LRO, LRO settings are ignored anyway
> and are removed here to avoid confusion.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
