From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] New maintainer for the mv643xx_eth driver
Date: Thu, 5 Jun 2008 18:13:20 +0200
Message-ID: <20080605161320.GA30083@xi.wantstofly.org>
References: <20080605131051.GA8019@farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, mlachwani@mvista.com
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:51617 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755451AbYFEQiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 12:38:52 -0400
Content-Disposition: inline
In-Reply-To: <20080605131051.GA8019@farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 05, 2008 at 06:10:51AM -0700, Dale Farnsworth wrote:

> With Lennert Buytenhek's recent improvements to the mv643xx_eth
> driver, it's become evident that he's committed to maintaining
> it.  Lennert has consented to taking over maintainership of the
> driver.  I'm pleased to pass the baton to someone who is as
> capable and motivated as Lennert.

Thanks!


> diff --git a/MAINTAINERS b/MAINTAINERS
> index 46fa179..83b0242 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -2690,12 +2690,10 @@ L:	libertas-dev@lists.infradead.org
>  S:	Maintained
>  
>  MARVELL MV643XX ETHERNET DRIVER
> -P:	Dale Farnsworth
> -M:	dale@farnsworth.org
> -P:	Manish Lachwani
> -M:	mlachwani@mvista.com
> +P:	Lennert Buytenhek
> +M:	kernel@wantstofly.org
>  L:	netdev@vger.kernel.org
> -S:	Odd Fixes for 2.4; Maintained for 2.6.
> +S:	Maintained

FWIW, this can be upgraded to "Supported" -- I'm actually paid to
look after this driver.
