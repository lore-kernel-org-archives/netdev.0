From: David Miller <davem@davemloft.net>
Subject: Re: Linux 2.6.22: Leak r=1 1
Date: Sun, 15 Jul 2007 00:20:11 -0700 (PDT)
Message-ID: <20070715.002011.09952517.davem@davemloft.net>
References: <20070711174030.tjmxpxtfsn4twgk2@m.safari.iki.fi>
	<Pine.LNX.4.64.0707120827280.12545@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: safari-kernel@safari.iki.fi, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36818
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753149AbXGOHUJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jul 2007 03:20:09 -0400
In-Reply-To: <Pine.LNX.4.64.0707120827280.12545@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 12 Jul 2007 10:53:57 +0300 (EEST)

> Dave can then put that one to net-2.6 and to stable too.
 ...
> [PATCH] [TCP]: Verify the presence of RETRANS bit when leaving FRTO
>=20
> For yet unknown reason, something cleared SACKED_RETRANS bit
> underneath FRTO.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, and I'll push to -stable.
