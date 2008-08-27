From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.27] myri10ge: update version string to 1.4.3-1.358
Date: Wed, 27 Aug 2008 05:18:20 -0400
Message-ID: <48B51BDC.5030609@garzik.org>
References: <48B475A8.7030608@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45228 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754795AbYH0JSY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:18:24 -0400
In-Reply-To: <48B475A8.7030608@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> Update myri10ge version string to 1.4.3-1.358.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
> drivers/net/myri10ge/myri10ge.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-2.6.git/drivers/net/myri10ge/myri10ge.c	2008-08-24 09:54:53.000000000 +0200
> +++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2008-08-26 23:21:42.000000000 +0200
> @@ -75,7 +75,7 @@
>  #include "myri10ge_mcp.h"
>  #include "myri10ge_mcp_gen_header.h"
>  
> -#define MYRI10GE_VERSION_STR "1.3.99-1.347"
> +#define MYRI10GE_VERSION_STR "1.4.3-1.358"
>  
>  MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
>  MODULE_AUTHOR("Maintainer: help@myri.com");

applied


