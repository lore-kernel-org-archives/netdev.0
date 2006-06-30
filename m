From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 1/5] remove dead entry in net wan Kconfig
Date: Fri, 30 Jun 2006 08:57:05 -0400
Message-ID: <44A51FA1.1080107@garzik.org>
References: <200606300927.k5U9RJRj001455@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, paulkf@microgate.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:29365 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932600AbWF3M5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 08:57:12 -0400
To: akpm@osdl.org
In-Reply-To: <200606300927.k5U9RJRj001455@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Paul Fulghum <paulkf@microgate.com>
> 
> Remove dead entry from net wan Kconfig and net wan Makefile..  This entry is
> left over from 2.4 where synclink used syncppp driver directly.  synclink
> drivers now use generic HDLC
> 
> Signed-off-by: Paul Fulghum <paulkf@microgate.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>
> ---
> 
>  drivers/net/wan/Kconfig  |   12 ------------
>  drivers/net/wan/Makefile |    1 -
>  2 files changed, 13 deletions(-)

queued this in my stack...


