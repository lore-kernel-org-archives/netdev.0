From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] [459/2many] MAINTAINERS - SPIDERNET NETWORK DRIVER for CELL
Date: Mon, 13 Aug 2007 10:45:48 -0500
Message-ID: <20070813154548.GA4338@austin.ibm.com>
References: <46bffbfa.6q67BtSh8n+UV4q4%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:56725 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968259AbXHMPpu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 11:45:50 -0400
Content-Disposition: inline
In-Reply-To: <46bffbfa.6q67BtSh8n+UV4q4%joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 12, 2007 at 11:36:42PM -0700, joe@perches.com wrote:
> Add file pattern to MAINTAINER entry
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index b616562..fa8fb1c 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4377,6 +4377,9 @@ P:	Linas Vepstas
>  M:	linas@austin.ibm.com
>  L:	netdev@vger.kernel.org
>  S:	Supported
> +F:	Documentation/networking/spider_net.txt
> +F:	arch/powerpc/platforms/cell/spider-pic.c
> +F:	drivers/net/spider_net*

Note quite right. spider-pic is not part of spider_net.
The rest loks fine.

--linas

