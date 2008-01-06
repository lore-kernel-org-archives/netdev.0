From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] [CCID3]: Kill some bloat
Date: Sat, 05 Jan 2008 23:13:38 -0800 (PST)
Message-ID: <20080105.231338.227948724.davem@davemloft.net>
References: <11995403483512-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1199540349385-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11995403493735-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, acme@redhat.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52163
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751582AbYAFHNi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jan 2008 02:13:38 -0500
In-Reply-To: <11995403493735-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat,  5 Jan 2008 15:39:08 +0200

> From: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>
>=20
> Without a number of CONFIG.*DEBUG:
>=20
> net/dccp/ccids/ccid3.c:
>   ccid3_hc_tx_update_x          | -170
>   ccid3_hc_tx_packet_sent       | -175
>   ccid3_hc_tx_packet_recv       | -169
>   ccid3_hc_tx_no_feedback_timer | -192
>   ccid3_hc_tx_send_packet       | -144
>  5 functions changed, 850 bytes removed, diff: -850
>=20
> net/dccp/ccids/ccid3.c:
>   ccid3_update_send_interval | +191
>  1 function changed, 191 bytes added, diff: +191
>=20
> net/dccp/ccids/ccid3.o:
>  6 functions changed, 191 bytes added, 850 bytes removed, diff: -659
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Also applied, thanks.
