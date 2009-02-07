From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] ipv6/addrconf: common code located
Date: Fri, 06 Feb 2009 23:49:28 -0800 (PST)
Message-ID: <20090206.234928.131296316.davem@davemloft.net>
References: <1233966063-2419-2-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1233966063-2419-3-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1233966063-2419-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42042
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753359AbZBGHtc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Feb 2009 02:49:32 -0500
In-Reply-To: <1233966063-2419-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat,  7 Feb 2009 02:21:03 +0200

> $ codiff net/ipv6/addrconf.o net/ipv6/addrconf.o.new
> net/ipv6/addrconf.c:
>  addrconf_notify | -267
> 1 function changed, 267 bytes removed
>=20
> net/ipv6/addrconf.c:
>  add_addr |  +86
> 1 function changed, 86 bytes added
>=20
> net/ipv6/addrconf.o.new:
> 2 functions changed, 86 bytes added, 267 bytes removed, diff: -181
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
