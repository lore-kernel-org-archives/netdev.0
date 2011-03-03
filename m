From: Pierre Ynard <linkfanel@yahoo.fr>
Subject: Re: [RFC][PATCH] Export DNSSL RA option to userspace
Date: Thu, 3 Mar 2011 02:27:58 +0100
Message-ID: <20110303012757.GA12872@via.ecp.fr>
References: <20101212144300.68e0fb16@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pierre-list@ossman.eu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb1-g21.free.fr ([212.27.42.9]:55376 "EHLO
	smtpfb1-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755229Ab1CCB1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 20:27:50 -0500
Received: from smtp2-g21.free.fr (smtp2-g21.free.fr [212.27.42.2])
	by smtpfb1-g21.free.fr (Postfix) with ESMTP id 71ED92C97F
	for <netdev@vger.kernel.org>; Thu,  3 Mar 2011 02:27:46 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20101212144300.68e0fb16@mjolnir.ossman.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Thanks for the patch!

> From a5b60e80eeed87763c811ecfb0d7aa5695d0a2bf Mon Sep 17 00:00:00 200=
1
> From: Pierre Ossman <pierre@xxxxxxxxx>
> Date: Sun, 12 Dec 2010 00:06:48 +0100
> Subject: [PATCH 1/2] ipv6: export DNS search list option to userspace
>=20
> Like DNS resolver addresses, the suffixes to be used in DNS lookups n=
eed
> to be configured by userspace. Make sure userspace has access to the
> option containing that information.
>=20
> Signed-off-by: Pierre Ossman <pierre@xxxxxxxxx>
> ---
>  include/net/ndisc.h |    3 ++-
>  net/ipv6/ndisc.c    |    8 +++++++-
>  2 files changed, 9 insertions(+), 2 deletions(-)

Acked-by: Pierre Ynard <linkfanel@yahoo.fr>

--=20
Pierre Ynard
"Une =E2me dans un corps, c'est comme un dessin sur une feuille de papi=
er."
