From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] MAINTAINERS: Add CAIF
Date: Thu, 09 Sep 2010 14:36:57 -0700 (PDT)
Message-ID: <20100909.143657.189709165.davem@davemloft.net>
References: <1283880791.23280.153.camel@Joe-Laptop>
	<81C3A93C17462B4BBD7E272753C1057916DE7CC568@EXDCVYMBSTM005.EQ1STM.local>
	<1283927604.2479.1.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58086
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753147Ab0IIVgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 17:36:39 -0400
In-Reply-To: <1283927604.2479.1.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 07 Sep 2010 23:33:24 -0700

> Signed-off-by: Joe Perches <joe@perches.com>

Saying something is "Supported" is a non-trivial commitment, so I'm
not applying this until there is at least some kind of ACK from
Sjur or one of the other CAIF hackers.

> ---
>  MAINTAINERS |   10 ++++++++++
>  1 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index c36f5d7..f2b3ece 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -1445,6 +1445,16 @@ S:	Maintained
>  F:	Documentation/video4linux/cafe_ccic
>  F:	drivers/media/video/cafe_ccic*
>  
> +CAIF NETWORK LAYER
> +M:	Sjur Braendeland <sjur.brandeland@stericsson.com>
> +L:	netdev@vger.kernel.org
> +S:	Supported
> +F:	Documentation/networking/caif/
> +F:	drivers/net/caif/
> +F:	include/linux/caif/
> +F:	include/net/caif/
> +F:	net/caif/
> +
>  CALGARY x86-64 IOMMU
>  M:	Muli Ben-Yehuda <muli@il.ibm.com>
>  M:	"Jon D. Mason" <jdmason@kudzu.us>
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
