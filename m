From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Call netdev_features_change() from
 netdev_update_features()
Date: Sat, 02 Apr 2011 22:50:19 -0700 (PDT)
Message-ID: <20110402.225019.241921171.davem@davemloft.net>
References: <20110402144141.0192613909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com, jesse@nicira.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45741
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751396Ab1DCFu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 01:50:57 -0400
In-Reply-To: <20110402144141.0192613909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sat,  2 Apr 2011 16:41:40 +0200 (CEST)

> Issue FEAT_CHANGE notification when features are changed by
> netdev_update_features().  This will allow changes made by extra cons=
traints
> on e.g. MTU change to be properly propagated like changes via ethtool=
=2E
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
