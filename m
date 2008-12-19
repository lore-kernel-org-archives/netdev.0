From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Stop scaring users with "treason uncloaked!"
Date: Thu, 18 Dec 2008 16:08:15 -0800 (PST)
Message-ID: <20081218.160815.106790562.davem@davemloft.net>
References: <1229638581.3726.546.camel@calx>
	<Pine.LNX.4.64.0812190028560.12061@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37324
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751629AbYLSAIO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 19:08:14 -0500
In-Reply-To: <Pine.LNX.4.64.0812190028560.12061@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 19 Dec 2008 00:33:46 +0200 (EET)

> On Thu, 18 Dec 2008, Matt Mackall wrote:
>=20
> > These debug messages are uninformative and extremely alarming. Rath=
er
> > than reporting a peer as a treacherous attacker, report it more
> > correctly as simply broken.=20
>=20
> Last time (well, ignoring some report on ancient vendor kernel) I've =
seen=20
> this to trigger it wasn't the fault of the peer but ours (we sent pas=
t the=20
> advertized window and window ended up being shrunk to zero). I agree =
that=20
> the message as-is is not very good but your change is not very good=20
> either.
 ...
> This won't apply to net-next on which you should base anything new (a=
nd=20
> net related).

Agreed.
