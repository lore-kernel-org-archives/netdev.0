From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: introduce netdev_change_features()
Date: Thu, 12 May 2011 15:40:44 -0700 (PDT)
Message-ID: <20110512.154044.183046180.davem@davemloft.net>
References: <20110507132217.0938E13A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34657
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752214Ab1ELWlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 18:41:16 -0400
In-Reply-To: <20110507132217.0938E13A6A@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sat,  7 May 2011 15:22:17 +0200 (CEST)

> It will be needed by bonding and other drivers changing vlan_features
> after ndo_init callback.
>=20
> As a bonus, this includes kernel-doc for netdev_update_features().
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
