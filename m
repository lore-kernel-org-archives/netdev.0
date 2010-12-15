From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Fix NETIF_F_HW_CSUM implementations [v2]
Date: Tue, 14 Dec 2010 17:29:32 -0800 (PST)
Message-ID: <20101214.172932.193707112.davem@davemloft.net>
References: <cover.1292372504.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55668
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750887Ab0LOB3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 20:29:04 -0500
In-Reply-To: <cover.1292372504.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Wed, 15 Dec 2010 02:24:08 +0100 (CET)

> This is a split version of a patch fixing NETIF_F_HW_CSUM implementat=
ions
> in network drivers. For easier review, this is split into three patch=
es:
>=20
>  1. introduce skb_checksum_start_offset() helper
>  2. convert correct implementations to use the helper from #1
>  3. fix bad uses of skb_transport_offset() using helper from #1

I don't have any idea why you'd CC: as the networking maintainer only
on some of these patches.

That doesn't make any sense at all.

Either CC: me on all of them, or none.  Don't partially CC: as that
makes it painful for me to manage my inbox.

Thank you.

