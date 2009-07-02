From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH net-2.6 6/6] jme: Advance driver version number
Date: Fri, 3 Jul 2009 03:16:46 +0800
Message-ID: <20090702191128.M54727@cooldavid.org>
References: <20090702183224.0B77E5D2D9@cooldavid.org>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: "netdev" <netdev@vger.kernel.org>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:48277 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799AbZGBTTj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2009 15:19:39 -0400
In-Reply-To: <20090702183224.0B77E5D2D9@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for this incorrect patch...
I forget to remove this out-dated patch file from my patch directory.

And not until now I realized that the commit time will take from
"format-patch" and affect the timestamp of mail.

I'll be more careful next time.. sorry all..

On Mon, 29 Jun 2009 04:59:38 +0800, Guo-Fu Tseng wrote
> Advance driver version number after modifications.
> 
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
> ---
>  drivers/net/jme.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/jme.h b/drivers/net/jme.h
> index db912f6..251abed 100644
> --- a/drivers/net/jme.h
> +++ b/drivers/net/jme.h
> @@ -25,7 +25,7 @@
>  #define __JME_H_INCLUDED__
> 
>  #define DRV_NAME	"jme"
> -#define DRV_VERSION	"1.0.4"
> +#define DRV_VERSION	"1.0.5"
>  #define PFX		DRV_NAME ": "
> 
>  #define PCI_DEVICE_ID_JMICRON_JMC250	0x0250
> -- 
> 1.6.0.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Guo-Fu Tseng

