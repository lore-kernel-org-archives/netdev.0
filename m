From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/10] spidernet: node-aware skbuff allocation
Date: Thu, 17 May 2007 20:46:00 -0400
Message-ID: <464CF748.4090101@garzik.org>
References: <20070516215605.GA4325@austin.ibm.com> <20070516215800.GA4997@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43561 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756315AbXERAqH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 20:46:07 -0400
In-Reply-To: <20070516215800.GA4997@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> From: Christoph Hellwig <hch@lst.de>
> 
> Spidernet was the driver I original did all the node-aware netdevice
> allocation for, but after a year it still hasn't hit mainline.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> 
> ----
> 
>  drivers/net/spider_net.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

applied


