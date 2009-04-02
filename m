From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tcp: add helper for counter tweaking due mid-wq
 change
Date: Thu, 02 Apr 2009 16:32:28 -0700 (PDT)
Message-ID: <20090402.163228.261255942.davem@davemloft.net>
References: <20090331184959.GA2725@gentoox2.trippelsdorf.de>
	<Pine.LNX.4.64.0904011352470.30150@wrl-59.cs.helsinki.fi>
	<Pine.LNX.4.64.0904021212310.30150@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: markus@trippelsdorf.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, uwe.bugla@gmx.de
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54620
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759575AbZDBXck convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 19:32:40 -0400
In-Reply-To: <Pine.LNX.4.64.0904021212310.30150@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 2 Apr 2009 12:15:17 +0300 (EEST)

> [PATCH 1/2] tcp: add helper for counter tweaking due mid-wq change
>=20
> We need full-scale adjustment to fix a TCP miscount in the next
> patch, so just move it into a helper and call for that from the
> other places.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
