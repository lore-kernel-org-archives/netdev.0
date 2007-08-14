From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH] [396/2many] MAINTAINERS - QLOGIC QLAxxx NETWORK DRIVER
Date: Tue, 14 Aug 2007 09:15:40 -0700
Message-ID: <20070814161540.GA4859@linux-7mw0.qlogic.org>
References: <46bffb79.Z5A395zbCgcCCCAB%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:37318 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754312AbXHNQPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 12:15:43 -0400
Content-Disposition: inline
In-Reply-To: <46bffb79.Z5A395zbCgcCCCAB%joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 12, 2007 at 11:34:33PM -0700, joe@perches.com wrote:
> Add file pattern to MAINTAINER entry
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 1fa922a..6a99fe5 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -3790,6 +3790,8 @@ P:	Ron Mercer
>  M:	linux-driver@qlogic.com
>  L:	netdev@vger.kernel.org
>  S:	Supported
> +F:	Documentation/networking/LICENSE.qla3xxx
> +F:	drivers/net/qla3xxx.*
>  
>  QNX4 FILESYSTEM
>  P:	Anders Larsen

Acked-by: Ron Mercer <ron.mercer@qlogic.com>
