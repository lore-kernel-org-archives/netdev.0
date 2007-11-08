From: Jeff Garzik <jeff@garzik.org>
Subject: Re: ax88796: add superh to kconfig dependencies
Date: Thu, 8 Nov 2007 12:47:58 -0500
Message-ID: <20071108174758.GE3011@havoc.gtf.org>
References: <20071108073105.3996.70418.sendpatchset@clockwork.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lethal@linux-sh.org, ben-linux@fluff.org,
	akpm@linux-foundation.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:53145 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760867AbXKHRr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 12:47:58 -0500
Content-Disposition: inline
In-Reply-To: <20071108073105.3996.70418.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 08, 2007 at 04:31:05PM +0900, Magnus Damm wrote:
> ax88796: add superh to kconfig dependencies
> 
> This patch adds sh architecture support to the ax88796 kconfig.
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>
> ---
> 
>  This patch was posted about a month ago but never picked up:
>  http://www.mail-archive.com/netdev@vger.kernel.org/msg50018.html
>  The rest of the sh support is already included in rc1. Please apply.
> 
>  drivers/net/Kconfig |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

applied


