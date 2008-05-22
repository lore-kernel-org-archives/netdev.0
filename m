From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.26 3/3]S2io: Version update for napi and MSI-X patches
Date: Thu, 22 May 2008 00:55:38 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77039B314F@nekter>
References: <Pine.GSO.4.10.10805121342210.18446-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "support" <support@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
To: <netdev@vger.kernel.org>, <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:35408 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751976AbYEVEzl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 00:55:41 -0400
Content-class: urn:content-classes:message
In-Reply-To: <Pine.GSO.4.10.10805121342210.18446-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What is the status of this set of patches?

Ram
> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Sreenivasa Honnur
> Sent: Monday, May 12, 2008 10:43 AM
> To: netdev@vger.kernel.org; jeff@garzik.org
> Cc: support
> Subject: [PATCH 2.6.26 3/3]S2io: Version update for napi and MSI-X
patches
> 
> - Updated version number
> 
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> ---
> diff -Nurp 2.0.26.24-P2/drivers/net/s2io.c
2.0.26.24-P3/drivers/net/s2io.c
> --- 2.0.26.24-P2/drivers/net/s2io.c	2008-05-08 15:37:57.000000000
-0700
> +++ 2.0.26.24-P3/drivers/net/s2io.c	2008-05-08 15:39:46.000000000
-0700
> @@ -86,7 +86,7 @@
>  #include "s2io.h"
>  #include "s2io-regs.h"
> 
> -#define DRV_VERSION "2.0.26.23"
> +#define DRV_VERSION "2.0.26.24"
> 
>  /* S2io Driver name & version. */
>  static char s2io_driver_name[] = "Neterion";
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
