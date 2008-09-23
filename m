From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/11] PhoNet protocols stack v2
Date: Mon, 22 Sep 2008 20:16:22 -0700 (PDT)
Message-ID: <20080922.201622.93200381.davem@davemloft.net>
References: <200809221845.54736.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57791
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755250AbYIWDQe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 23:16:34 -0400
In-Reply-To: <200809221845.54736.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Mon, 22 Sep 2008 18:45:54 +0300

> =A0=A0=A0=A0=A0=A0=A0=A0Hello,
>=20
> This patch series is the second attempt at support for PhoNet network=
 protocol=20
> stack in the Linux kernel and trying to address various comments alre=
ady=20
> received on the mailing list. This protocol is the primary interface =
to Nokia=20
> cellular modem engines. We are integrating it to the Linux kernel in =
order to=20
> support HSPA cellular data connectivity on the Maemo Software platfor=
m.
>=20
> This patchset provides a "raw" datagram protocol as a starting point,=
 and is=20
> based on the current net-next-2.6.
>=20
> Any comments welcome.

This seems good enough to initially merge, so I applied all of these
patches to net-next-2.6

Please send any bug fixes or updates relative to this, thanks!
