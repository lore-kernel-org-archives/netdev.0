From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] (3/12) skge: remove unneeded include's
Date: Thu, 03 Mar 2005 16:41:04 -0500
Message-ID: <42278470.2070807@pobox.com>
References: <20050303113413.1bcd7476@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050303113413.1bcd7476@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Get rid of unnecessary include's
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> --- skge-2.6.11/drivers/net/skge.c.orig	2005-03-02 17:15:44.000000000 -0800
> +++ skge-2.6.11/drivers/net/skge.c	2005-03-02 17:17:25.000000000 -0800
> @@ -30,13 +30,10 @@
>  #include <linux/moduleparam.h>
>  #include <linux/netdevice.h>
>  #include <linux/etherdevice.h>
> -#include <linux/dma-mapping.h>

Why is this one is unnecessary?
