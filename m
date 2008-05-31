From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.26] myri10ge: update driver version
Date: Fri, 30 May 2008 22:12:46 -0400
Message-ID: <4840B41E.5060405@garzik.org>
References: <483D0549.1010208@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37095 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751885AbYEaCMt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 22:12:49 -0400
In-Reply-To: <483D0549.1010208@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> Update myri10ge version to 1.3.99-1.347.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
> Hello Jeff,
> 
> Please apply this patch for 2.6.26 to reflect the driver status
> (contains all our 1.4 bugfixes without multislice support).
> 
> You should also drop the correponding last patch from your upstream-myri
> branch (commit id d1d0b191365b2606cf09631805f07b81ab005d7e) before pushing
> to davem' net-next-2.6. I'll send a new one during the 2.6.27 cycle.
> 
> thanks,
> Brice
> 
>  drivers/net/myri10ge/myri10ge.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

applied


