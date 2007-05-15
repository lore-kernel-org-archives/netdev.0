From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch/resend] smc911x: fix compilation breakage
Date: Tue, 15 May 2007 17:45:07 -0400
Message-ID: <464A29E3.202@garzik.org>
References: <464723C0.70409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmk@arm.linux.org.uk
To: Vitaly Wool <vitalywool@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50837 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755624AbXEOVpJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 17:45:09 -0400
In-Reply-To: <464723C0.70409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vitaly Wool wrote:
> Looks like the new version of this patch has been overlooked,
> so I'm resending it.
> 
> It just adapts the driver to the new IRQ API
> according to what Russell has pointed out.
> 
> drivers/net/smc911x.c |    6 ++----
> 1 files changed, 2 insertions(+), 4 deletions(-)
> 
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

applied to #upstream-fixes


