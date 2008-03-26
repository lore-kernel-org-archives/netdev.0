From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Patch 2.6.25 2/2]S2io: Version update for Tx completion patch
Date: Tue, 25 Mar 2008 23:21:04 -0400
Message-ID: <47E9C120.1040009@garzik.org>
References: <Pine.GSO.4.10.10803251512010.22948-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43469 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755427AbYCZDVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 23:21:06 -0400
In-Reply-To: <Pine.GSO.4.10.10803251512010.22948-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> - Updated version number.
> 
> Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> ---
> diff -Nurp 2-0-26-21-1/drivers/net/s2io.c 2-0-26-21-2/drivers/net/s2io.c
> --- 2-0-26-21-1/drivers/net/s2io.c	2008-03-20 10:22:25.000000000 +0530
> +++ 2-0-26-21-2/drivers/net/s2io.c	2008-03-20 10:36:33.000000000 +0530
> @@ -86,7 +86,7 @@
>  #include "s2io.h"
>  #include "s2io-regs.h"
>  
> -#define DRV_VERSION "2.0.26.19"
> +#define DRV_VERSION "2.0.26.20"
>  
>  /* S2io Driver name & version. */
>  static char s2io_driver_name[] = "Neterion";

patch failed to apply


