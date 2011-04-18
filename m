From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: greth: convert to hw_features
Date: Sun, 17 Apr 2011 17:44:29 -0700 (PDT)
Message-ID: <20110417.174429.235683790.davem@davemloft.net>
References: <20110417101547.D59E313A6F@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47345
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753869Ab1DRApD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:45:03 -0400
In-Reply-To: <20110417101547.D59E313A6F@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sun, 17 Apr 2011 12:15:47 +0200 (CEST)

> Note: Driver modifies its struct net_device_ops. This will break if u=
sed for
> multiple devices that are not all the same (if that HW config is poss=
ible).
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

I guess for how this chip is used, this is OK for now.

Applied.
