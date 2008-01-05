From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 4/4] [CCID3]: Kill some bloat
Date: Sat, 5 Jan 2008 12:44:12 -0200
Message-ID: <20080105144412.GC12379@ghostprotocols.net>
References: <11995403482366-git-send-email-ilpo.jarvinen@helsinki.fi> <11995403481730-git-send-email-ilpo.jarvinen@helsinki.fi> <11995403483512-git-send-email-ilpo.jarvinen@helsinki.fi> <1199540349385-git-send-email-ilpo.jarvinen@helsinki.fi> <11995403493735-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41084 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753793AbYAEOoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2008 09:44:22 -0500
Content-Disposition: inline
In-Reply-To: <11995403493735-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sat, Jan 05, 2008 at 03:39:08PM +0200, Ilpo J=E4rvinen escreveu:
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

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
