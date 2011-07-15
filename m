From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: rx parser
Date: Fri, 15 Jul 2011 16:00:37 -0700 (PDT)
Message-ID: <20110715.160037.1647693804563597586.davem@davemloft.net>
References: <1310728141.28792.10.camel@DENEC1DT0191>
	<20110715.080610.256697325487445331.davem@davemloft.net>
	<20110715195133.GA3499@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sebastian.belden@googlemail.com, netdev@vger.kernel.org,
	sandeep.kumar@freescale.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980Ab1GOXAy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 19:00:54 -0400
In-Reply-To: <20110715195133.GA3499@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 15 Jul 2011 21:51:34 +0200

> From: Sebastian P=F6hn <sebastian.belden@googlemail.com>
> Subject: [patch net-next-2.6] gianfar: rx parser
>=20
> Only let the rx parser be enabled if it is necessary (if VLAN extract=
ion,
> IP or TCP checksumming or the rx queue filer are enabled). Otherwise
> disable it.
>=20
> The new routine gfar_check_rx_parser_mode should be run after every
> change on this features and will enable/disable the parser as necessa=
ry.
>=20
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>

Applied, thanks.
