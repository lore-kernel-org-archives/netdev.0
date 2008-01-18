From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000e Kconfig: remove ref to nonexistant docs
Date: Fri, 18 Jan 2008 14:40:25 -0500
Message-ID: <479100A9.2070209@garzik.org>
References: <20080117070317.GA7922@aurum.uhlenkott.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Auke Kok <auke-jan.h.kok@intel.com>
To: Jason Uhlenkott <jasonuhl@jasonuhl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52229 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756823AbYARTk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 14:40:28 -0500
In-Reply-To: <20080117070317.GA7922@aurum.uhlenkott.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason Uhlenkott wrote:
> There is no Documentation/networking/e1000e.txt.
> 
> Signed-off-by: Jason Uhlenkott <jasonuhl@jasonuhl.org>
> Cc: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
> Index: linux/drivers/net/Kconfig
> ===================================================================
> --- linux.orig/drivers/net/Kconfig	2008-01-16 17:48:03.041103083 -0800
> +++ linux/drivers/net/Kconfig	2008-01-16 23:00:23.647430487 -0800
> @@ -1976,9 +1976,6 @@
>  
>  	  <http://support.intel.com>
>  
> -	  More specific information on configuring the driver is in
> -	  <file:Documentation/networking/e1000e.txt>.
> -
>  	  To compile this driver as a module, choose M here. The module
>  	  will be called e1000e.

applied


