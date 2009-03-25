From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove two duplicated include
Date: Tue, 24 Mar 2009 23:24:32 -0700 (PDT)
Message-ID: <20090324.232432.223289131.davem@davemloft.net>
References: <20090325033132.GA7060@ubuntu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jianjun@zeuux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46737
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754188AbZCYGYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 02:24:44 -0400
In-Reply-To: <20090325033132.GA7060@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianjun Kong <jianjun@zeuux.org>
Date: Wed, 25 Mar 2009 11:31:32 +0800

> diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
> index 5c347f7..8a98d40 100644
> --- a/drivers/net/dnet.c
> +++ b/drivers/net/dnet.c
> @@ -21,7 +21,6 @@
>  #include <linux/dma-mapping.h>
>  #include <linux/platform_device.h>
>  #include <linux/phy.h>
> -#include <linux/platform_device.h>
>  
>  #include "dnet.h"
>  
> -- 
> 1.5.6.3
> 

This one is already in the net-next-2.6 tree
