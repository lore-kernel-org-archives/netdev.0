From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation (v4)
Date: Tue, 16 Nov 2010 16:30:26 -0500
Message-ID: <20101116213026.GA8309@hmsreliant.think-freely.org>
References: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
 <1289416194-1844-1-git-send-email-nhorman@tuxdriver.com>
 <20101116.102537.246547550.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	zenczykowski@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50399 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757325Ab0KPVdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 16:33:42 -0500
Content-Disposition: inline
In-Reply-To: <20101116.102537.246547550.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 16, 2010 at 10:25:37AM -0800, David Miller wrote:
> From: nhorman@tuxdriver.com
> Date: Wed, 10 Nov 2010 14:09:54 -0500
> 
> > Version 4 of this patch.
> 
> Applied, thanks a lot for doing this.
No problem, thanks!
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
