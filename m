From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] ne2: silence static never defined warnings
Date: Fri, 28 Nov 2008 15:55:09 -0800 (PST)
Message-ID: <20081128.155509.166145452.davem@davemloft.net>
References: <12278948183224-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12278948182487-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227894818582-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45098
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752995AbYK1XzJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Nov 2008 18:55:09 -0500
In-Reply-To: <1227894818582-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 28 Nov 2008 19:53:38 +0200

> These warning originate from 50014f1 (ne2: convert to
> net_device_ops) which did drop those functions.
>=20
> drivers/net/ne2.c:140: warning: 'ne_open' declared 'static' but never=
 defined
> drivers/net/ne2.c:141: warning: 'ne_close' declared 'static' but neve=
r defined
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Also applied, thanks Ilpo.
