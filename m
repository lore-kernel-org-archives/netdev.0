From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [TCP]: Create tcp_mark_head_lost_single for
 NewReno
Date: Wed, 05 Dec 2007 02:39:47 -0800 (PST)
Message-ID: <20071205.023947.118293079.davem@davemloft.net>
References: <Pine.LNX.4.64.0712051217380.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50414
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751270AbXLEKjr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 05:39:47 -0500
In-Reply-To: <Pine.LNX.4.64.0712051217380.18529@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 5 Dec 2007 12:19:04 +0200 (EET)

>=20
> Fixes NewReno breakage that got introduced because reno ended up
> into RFC3517 counting branch in tcp_mark_head_lost after the
> split space tweaks. The fack branch would have worked, however,
> coming lost marker updates would eventually add this anyway.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks Ilpo.
