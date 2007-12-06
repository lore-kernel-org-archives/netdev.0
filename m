From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Make invariant check complain about invalid
 sacked_out
Date: Wed, 05 Dec 2007 21:22:17 -0800 (PST)
Message-ID: <20071205.212217.221493551.davem@davemloft.net>
References: <Pine.LNX.4.64.0712052133490.9572@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0712052135530.9572@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49733
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751568AbXLFFWR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 00:22:17 -0500
In-Reply-To: <Pine.LNX.4.64.0712052135530.9572@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 5 Dec 2007 21:36:37 +0200 (EET)

> On Wed, 5 Dec 2007, Ilpo J=E4rvinen wrote:
>=20
> >=20
> > Earlier resolution for NewReno's sacked_out should now keep
> > it small enough for this to become invariant-like check.
> >=20
> > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Forgot to modify it to the subject, this one to net-2.6.25 please.

Applied to net-2.6.25, thanks!
