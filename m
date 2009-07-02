From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH 9/9] vxge: Version update
Date: Thu, 02 Jul 2009 09:27:03 +0200
Message-ID: <4A4C6147.7030700@gmail.com>
References: <Pine.GSO.4.10.10907020318070.13763-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47861 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685AbZGBH1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 03:27:14 -0400
In-Reply-To: <Pine.GSO.4.10.10907020318070.13763-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur a =E9crit :
> - Version update
>=20
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> ---
> diff -urpN patch_8/drivers/net/vxge/vxge-version.h patch_9/drivers/ne=
t/vxge/vxge-version.h
> --- patch_8/drivers/net/vxge/vxge-version.h	2009-06-30 12:14:09.00000=
0000 +0530
> +++ patch_9/drivers/net/vxge/vxge-version.h	2009-06-30 12:47:50.00000=
0000 +0530
> @@ -18,6 +18,6 @@
>  #define VXGE_VERSION_MAJOR	"2"
>  #define VXGE_VERSION_MINOR	"0"
>  #define VXGE_VERSION_FIX	"4"
> -#define VXGE_VERSION_BUILD	"17795"
> +#define VXGE_VERSION_BUILD	"17899"
>  #define VXGE_VERSION_FOR	"k"
>  #endif
>=20

Just curious, why do you change only BUILD, after all previous changes
that seem quite important, like requiring a new firmware (see patch 7/9=
) and or
fixing crash issues ?

