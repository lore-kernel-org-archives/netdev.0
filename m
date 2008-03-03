From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [E1000-devel] [PATCH 4/4] Intel ethernet adapter: Update MAINTAINERS
Date: Mon, 03 Mar 2008 14:48:22 -0800
Message-ID: <47CC8036.6040400@intel.com>
References: <20080303223731.16344.94975.stgit@localhost.localdomain> <20080303223747.16344.11861.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2011 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752470AbYCCWuN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 17:50:13 -0500
In-Reply-To: <20080303223747.16344.11861.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> Another team member unfortunately left: update MAINTAINERS.
> 
> Condense the 3 lists down to a single list for all our drivers.
> 
> Point to our new sourceforge index page which is slightly
> better navigateable than the sf.net project page.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  MAINTAINERS |   32 ++++----------------------------
>  1 files changed, 4 insertions(+), 28 deletions(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 2333255..a945724 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -2033,43 +2033,19 @@ M:	kernel@wantstofly.org
>  L:	netdev@vger.kernel.org
>  S:	Maintained
>  
> -INTEL PRO/100 ETHERNET SUPPORT
> +INTEL ETHERNET DRIVERS (e100/e1000/e1000e/igb/ixgb/ixgbe)
>  P:	Auke Kok
>  M:	auke-jan.h.kok@intel.com
>  P:	Jesse Brandeburg
>  M:	jesse.brandeburg@intel.com
>  P:	Jeff Kirsher
>  M:	jeffrey.t.kirsher@intel.com
> +P:	Bruce Allan
> +M:	bruce.w.allan@intel.com
>  P:	John Ronciak
>  M:	john.ronciak@intel.com
>  L:	e1000-devel@lists.sourceforge.net
> -W:	http://sourceforge.net/projects/e1000/
> -S:	Supported
> -
> -INTEL PRO/1000 GIGABIT ETHERNET SUPPORT
> -P:	Auke Kok
> -M:	auke-jan.h.kok@intel.com
> -P:	Jesse Brandeburg
> -M:	jesse.brandeburg@intel.com
> -P:	Jeff Kirsher
> -M:	jeffrey.t.kirsher@intel.com
> -P:	John Ronciak
> -M:	john.ronciak@intel.com
> -L:	e1000-devel@lists.sourceforge.net
> -W:	http://sourceforge.net/projects/e1000/
> -S:	Supported
> -
> -INTEL PRO/10GbE SUPPORT
> -P:	Ayyappan Veeraiyan
> -M:	ayyappan.veeraiyan@intel.com
> -P:	Auke Kok
> -M:	auke-jan.h.kok@intel.com
> -P:	Jesse Brandeburg
> -M:	jesse.brandeburg@intel.com
> -P:	John Ronciak
> -M:	john.ronciak@intel.com
> -L:	e1000-devel@lists.sourceforge.net
> -W:	http://sourceforge.net/projects/e1000/
> +W:	http://e1000.sourceforge.net/
>  S:	Supported
>  
>  INTEL PRO/WIRELESS 2100 NETWORK CONNECTION SUPPORT

ok, I should have reordered this.

patch 1, 2 and 4 are for upstream-fixes
patch #3 is for #upstream

thanks,

Auke

