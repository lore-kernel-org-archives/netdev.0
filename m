From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] mv643xx: Clear pending interrupts before calling request_irq
Date: Fri, 09 Mar 2007 11:52:15 -0500
Message-ID: <45F190BF.3050007@garzik.org>
References: <20070306164638.GB22043@xyzzy.farnsworth.org> <983376.58847.qm@web32410.mail.mud.yahoo.com> <20070308052123.GA5077@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	giri@lmc.cs.sunysb.edu, Giridhar Pemmasani <pgiri@yahoo.com>
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57811 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767400AbXCIQwV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 11:52:21 -0500
In-Reply-To: <20070308052123.GA5077@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
> From: Dale Farnsworth <dale@farnsworth.org>
> 
> Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> Acked-by: Giridhar Pemmasani <pgiri@yahoo.com>
> 
> ---
> 
> Giri, thank you very much for reporting the problem and confirming
> the fix.
> 
> Jeff, please apply.
> 
> Andrew, this patch supersedes the -mm patch:
> 	mv643xx-ethernet-driver-irq-registration-fix.patch
> 
>  drivers/net/mv643xx_eth.c |   10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)

applied


