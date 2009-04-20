From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix mid-wq adjustment helper
Date: Mon, 20 Apr 2009 02:16:09 -0700 (PDT)
Message-ID: <20090420.021609.49729022.davem@davemloft.net>
References: <Pine.LNX.4.64.0904181828200.3691@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48380
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752714AbZDTJQR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 05:16:17 -0400
In-Reply-To: <Pine.LNX.4.64.0904181828200.3691@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 18 Apr 2009 18:48:48 +0300 (EEST)

>=20
> Just noticed while doing some new work that the recent
> mid-wq adjustment logic will misbehave when FACK is not
> in use (happens either due sysctl'ed off or auto-detected
> reordering) because I forgot the relevant TCPCB tagbit.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thank you!
