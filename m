From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [Patch 2.6.25 1/1]S2io: Version update for Tx completion patch
Date: Fri, 28 Mar 2008 21:53:50 -0400
Message-ID: <47EDA12E.9060008@garzik.org>
References: <Pine.GSO.4.10.10803281730500.11037-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55103 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755807AbYC2Bxw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 21:53:52 -0400
In-Reply-To: <Pine.GSO.4.10.10803281730500.11037-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> - Updated version number.
> - Resubmitting with correct version update.
> - this patch to be applied for upstream-davem branch
> 
> Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> ---
> diff -Nurp 2-0-26-21-1/drivers/net/s2io.c 2-0-26-21-2/drivers/net/s2io.c
> --- 2-0-26-21-1/drivers/net/s2io.c	2008-03-20 10:22:25.000000000 +0530
> +++ 2-0-26-21-2/drivers/net/s2io.c	2008-03-20 10:36:33.000000000 +0530
> @@ -86,7 +86,7 @@
>  #include "s2io.h"
>  #include "s2io-regs.h"
>  
> -#define DRV_VERSION "2.0.26.15-2"
> +#define DRV_VERSION "2.0.26.20"
>  
>  /* S2io Driver name & version. */
>  static char s2io_driver_name[] = "Neterion";

applied


