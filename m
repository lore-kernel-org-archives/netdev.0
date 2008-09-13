From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH resend] r6040: remove unused includes
Date: Sat, 13 Sep 2008 15:30:06 -0400
Message-ID: <48CC14BE.1060803@garzik.org>
References: <200809031647.17981.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50139 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753195AbYIMTaJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:30:09 -0400
In-Reply-To: <200809031647.17981.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:
> This patch removes all unused includes.
> 
> Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
> ---
> diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
> index 6531ff5..d453987 100644
> --- a/drivers/net/r6040.c
> +++ b/drivers/net/r6040.c
> @@ -24,13 +24,9 @@
>  
>  #include <linux/kernel.h>
>  #include <linux/module.h>
> -#include <linux/version.h>
> -#include <linux/moduleparam.h>
> -#include <linux/string.h>
>  #include <linux/timer.h>
>  #include <linux/errno.h>
>  #include <linux/ioport.h>
> -#include <linux/slab.h>
>  #include <linux/interrupt.h>
>  #include <linux/pci.h>
>  #include <linux/netdevice.h>
> @@ -45,9 +41,6 @@

applied


