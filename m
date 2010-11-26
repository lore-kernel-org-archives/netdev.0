From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH] MAINTAINERS: add second list for IRDA
Date: Fri, 26 Nov 2010 13:09:21 +0100
Message-ID: <20101126120920.GK5520@sortiz-mobl>
References: <1290535813-7487-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37269 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754134Ab0KZMJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Nov 2010 07:09:23 -0500
Content-Disposition: inline
In-Reply-To: <1290535813-7487-1-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wolfgang,

On Tue, Nov 23, 2010 at 07:10:13PM +0100, Wolfram Sang wrote:
> The irda-users-list is currently almost dead and subscribers-only. Adding
> netdev increases the audience which might help to not overlook a bugreport
> (again).
Makes sense. I'll carry this patch, thanks.

Cheers,
Samuel.


> Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
> Cc: Samuel Ortiz <sameo@linux.intel.com>
> Cc: David Miller <davem@davemloft.net>
> ---
>  MAINTAINERS |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 8b6ca96..2596a78 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -3261,6 +3261,7 @@ F:	net/ipx/
>  IRDA SUBSYSTEM
>  M:	Samuel Ortiz <samuel@sortiz.org>
>  L:	irda-users@lists.sourceforge.net (subscribers-only)
> +L:	netdev@vger.kernel.org
>  W:	http://irda.sourceforge.net/
>  S:	Maintained
>  T:	git git://git.kernel.org/pub/scm/linux/kernel/git/sameo/irda-2.6.git
> -- 
> 1.7.2.3
> 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
