From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] MAINTAINERS: remove me from tulip
Date: Thu, 9 Dec 2010 14:33:40 -0700
Message-ID: <20101209213340.GB26182@lackof.org>
References: <20101209195008.GV25668@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@redhat.com, grundler@parisc-linux.org
To: Kyle McMartin <kyle@mcmartin.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:42300 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754145Ab0LIVmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 16:42:11 -0500
Content-Disposition: inline
In-Reply-To: <20101209195008.GV25668@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 09, 2010 at 02:50:08PM -0500, Kyle McMartin wrote:
> It was a nice idea, but -ENOTIME and -ENOHW. I never got around to doing
> a lot of the clean up that I intended to.
> 
> Signed-off-by: Kyle McMartin <kyle@mcmartin.ca>

Yeah, I can understand. I basically just review incoming patches and
haven't done any work on the outstanding bugs over the past year or so.

Acked-by: Grant Grundler <grundler@parisc-linux.org>

Dave, please apply.

thanks,
grant

> ---
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 1a1c27b..a54a738 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -5932,7 +5932,6 @@ F:	include/linux/tty.h
>  
>  TULIP NETWORK DRIVERS
>  M:	Grant Grundler <grundler@parisc-linux.org>
> -M:	Kyle McMartin <kyle@mcmartin.ca>
>  L:	netdev@vger.kernel.org
>  S:	Maintained
>  F:	drivers/net/tulip/
