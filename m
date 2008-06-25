From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch v3 01/12] DM9000: Remove the 2 resources probe scheme.
Date: Tue, 24 Jun 2008 23:06:37 -0400
Message-ID: <4861B63D.1010509@garzik.org>
References: <20080624211556.566149406@fluff.org.uk> <20080624211903.586586947@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, laurentp@cse-semaphore.com
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36901 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752376AbYFYDGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 23:06:41 -0400
In-Reply-To: <20080624211903.586586947@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Dooks wrote:
> From: Laurent Pinchart <laurentp@cse-semaphore.com>
> 
> The dm9000 driver accepts either 2 or 3 resources to describe the platform
> devices. The 2 resources case abuses the ioresource mechanism by passing
> ioremap()ed memory through the platform device resources. This patch removes
> that case and converts boards that were using it to the 3 resources scheme.
> 
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>

applied 1-12


