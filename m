From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TIPC] Kill unused static inline (x5)
Date: Thu, 07 Feb 2008 18:17:24 -0800 (PST)
Message-ID: <20080207.181724.253521208.davem@davemloft.net>
References: <12013021583862-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: per.liden@ericsson.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46697
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753183AbYBHCQx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 21:16:53 -0500
In-Reply-To: <12013021583862-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 26 Jan 2008 01:02:38 +0200

> All these static inlines are unused:
>=20
> in_own_zone     1 (net/tipc/addr.h)
> msg_dataoctet   1 (net/tipc/msg.h)
> msg_direct      1 (include/net/tipc/tipc_msg.h)
> msg_options     1 (include/net/tipc/tipc_msg.h)
> tipc_nmap_get   1 (net/tipc/bcast.h)
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
