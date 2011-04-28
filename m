From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: convert br_features_recompute() to
 ndo_fix_features
Date: Thu, 28 Apr 2011 13:33:36 -0700 (PDT)
Message-ID: <20110428.133336.179923999.davem@davemloft.net>
References: <20110422163116.5BAE713A64@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55223
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932561Ab1D1UeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 16:34:09 -0400
In-Reply-To: <20110422163116.5BAE713A64@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Fri, 22 Apr 2011 18:31:16 +0200 (CEST)

> Note: netdev_update_features() needs only rtnl_lock as br->port_list
> is only changed while holding it.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
