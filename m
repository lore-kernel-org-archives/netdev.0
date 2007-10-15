From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: high_seq parameter removed (all callers use
 tp->high_seq)
Date: Mon, 15 Oct 2007 02:10:42 -0700 (PDT)
Message-ID: <20071015.021042.31429383.davem@davemloft.net>
References: <Pine.LNX.4.64.0710121640200.3767@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58141
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754192AbXJOJKl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 05:10:41 -0400
In-Reply-To: <Pine.LNX.4.64.0710121640200.3767@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 12 Oct 2007 17:02:18 +0300 (EEST)

>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>=20
> Compile tested with 2.6.23 as current Linus' tree provides an
> hilarious building failure to our net-2.6 sandbox... :-)

Applied, thanks :-)
