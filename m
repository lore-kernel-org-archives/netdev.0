From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 06/11] dm9000-use-delayed-work-to-update-mii-phy-state-fix
Date: Thu, 22 May 2008 06:03:46 -0400
Message-ID: <48354502.1040708@garzik.org>
References: <200805142320.m4ENKDWX026626@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben-linux@fluff.org,
	enrico.scholz@sigma-chemnitz.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40544 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762397AbYEVKDt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:03:49 -0400
In-Reply-To: <200805142320.m4ENKDWX026626@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> use cancel_delayed_work_sync()
> 
> Cc: Ben Dooks <ben-linux@fluff.org>
> Cc: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/dm9000.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

applied


