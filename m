From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] fix arm/etherh.c allocation
Date: Wed, 21 Apr 2004 23:28:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40873BEA.1040208@pobox.com>
References: <200404202049.09130.daniel.ritz@gmx.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Russell King <rmk+lkml@arm.linux.org.uk>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: daniel.ritz@gmx.ch
In-Reply-To: <200404202049.09130.daniel.ritz@gmx.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Daniel Ritz wrote:
> russell, there's a part of my original patch you missed: allocation of the
> netdevice. doesn't need a comment.
> 
> against 2.6-bknow
> 
> rgds
> -daniel 
> 
> 
> --- 1.23/drivers/net/arm/etherh.c	Wed Apr 14 12:23:55 2004
> +++ edited/etherh.c	Tue Apr 20 20:39:04 2004


can one of you resend something that applies with 'patch -sp1'?

	Jeff
