From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sunrpc/xprtsock.c: some common code found
Date: Fri, 06 Feb 2009 23:49:40 -0800 (PST)
Message-ID: <20090206.234940.99301852.davem@davemloft.net>
References: <Pine.LNX.4.64.0902062247500.31842@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42045
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753276AbZBGHto convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Feb 2009 02:49:44 -0500
In-Reply-To: <Pine.LNX.4.64.0902062247500.31842@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 6 Feb 2009 22:51:17 +0200 (EET)

>=20
> $ diff-funcs xs_udp_write_space net/sunrpc/xprtsock.c
=2E..
> $ codiff net/sunrpc/xprtsock.o net/sunrpc/xprtsock.o.new
> net/sunrpc/xprtsock.c:
>   xs_tcp_write_space | -163
>   xs_udp_write_space | -163
>  2 functions changed, 326 bytes removed
>=20
> net/sunrpc/xprtsock.c:
>   xs_write_space | +179
>  1 function changed, 179 bytes added
>=20
> net/sunrpc/xprtsock.o.new:
>  3 functions changed, 179 bytes added, 326 bytes removed, diff: -147
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
