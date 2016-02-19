From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] MAINTAINERS: Drop myself as xen netback maintainer
Date: Fri, 19 Feb 2016 11:50:06 +0000
Message-ID: <20160219115006.GS3723@citrix.com>
References: <1455882291-1867-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:53574 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1427811AbcBSLuI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 06:50:08 -0500
Content-Disposition: inline
In-Reply-To: <1455882291-1867-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 11:44:51AM +0000, Ian Campbell wrote:
> Wei has been picking this up for quite a while now.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

> ---
>  MAINTAINERS | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 28eb61b..ef30060 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -12013,7 +12013,6 @@ F:	arch/arm64/xen/
>  F:	arch/arm64/include/asm/xen/
>  
>  XEN NETWORK BACKEND DRIVER
> -M:	Ian Campbell <ian.campbell@citrix.com>
>  M:	Wei Liu <wei.liu2@citrix.com>
>  L:	xen-devel@lists.xenproject.org (moderated for non-subscribers)
>  L:	netdev@vger.kernel.org
> -- 
> 2.1.4
> 
