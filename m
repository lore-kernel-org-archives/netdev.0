From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/10] [TCP]: Create tcp_sacktag_one().
Date: Thu, 15 Nov 2007 19:45:27 -0800 (PST)
Message-ID: <20071115.194527.187894086.davem@davemloft.net>
References: <1195133854614-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11951338543774-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11951338541495-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53516
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757609AbXKPDp2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 22:45:28 -0500
In-Reply-To: <11951338541495-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 15 Nov 2007 15:37:31 +0200

> Worker function that implements the main logic of
> the inner-most loop of tcp_sacktag_write_queue().
>=20
> Idea was originally presented by David S. Miller.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

How wonderful this change did not rot forever :-)

Thanks for keeping it alive, applied to net-2.6.25, thanks!
