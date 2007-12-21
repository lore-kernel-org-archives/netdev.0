From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC] [v2] TCP: use non-delayed ACK for congestion
 control RTT
Date: Fri, 21 Dec 2007 03:14:00 -0800 (PST)
Message-ID: <20071221.031400.194877955.davem@davemloft.net>
References: <Pine.LNX.4.64.0712191241450.11908@kivilampi-30.cs.helsinki.fi>
	<20071219113125.GF31508@nuim.ie>
	<Pine.LNX.4.64.0712191511120.14629@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gavin.McCullagh@nuim.ie, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55995
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754667AbXLULOA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 06:14:00 -0500
In-Reply-To: <Pine.LNX.4.64.0712191511120.14629@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 19 Dec 2007 15:30:03 +0200 (EET)

> On Wed, 19 Dec 2007, Gavin McCullagh wrote:
>=20
> > Will do.   I gather I should use the latest net- tree in future whe=
n
> > submitting patches.
>=20
> Doh, I owe you apology as I was probably too hasty to point you towar=
ds=20
> net-2.6.25. I suppose this could by considered as fix as well and=20
> therefore could probably be accepted to net-2.6 as well, which is for=
=20
> bugfixes only after merge window is closed. But it's Dave how will ma=
ke=20
> such decisions, not me :-), and it's he who gets to deal with all=20
> the resulting conflicts ;-) (I added Cc to him).

When Gavin respins the patch I'll look at in the context of submitting
it as a bug fix.  So Gavin please generate the patch against Linus's
vanilla GIT tree or net-2.6, your choise.
