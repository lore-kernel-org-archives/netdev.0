From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 08/17] tcp: separate timeout marking loop to
 it's own function
Date: Mon, 02 Mar 2009 03:02:05 -0800 (PST)
Message-ID: <20090302.030205.07412537.davem@davemloft.net>
References: <12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322831147-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322833102-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59057
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757144AbZCBLCY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 06:02:24 -0500
In-Reply-To: <12358322833102-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 28 Feb 2009 16:44:33 +0200

> From: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Some comment about its current state added. So far I have
> seen very few cases where the thing is actually useful,
> usually just marginally (though admittedly I don't usually
> see top of window losses where it seems possible that there
> could be some gain), instead, more often the cases suffer
> from L-marking spike which is certainly not desirable
> (I'll bury improving it to my todo list, but on a low
> prio position).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
