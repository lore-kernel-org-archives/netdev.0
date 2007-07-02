From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] spidernet: Replace literal with const
Date: Mon, 02 Jul 2007 08:37:36 -0400
Message-ID: <4688F190.1080304@garzik.org>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com> <20070611182650.GD13741@austin.ibm.com> <46704F90.7050508@garzik.org> <20070614231223.GZ4397@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51118 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753263AbXGBMho (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:37:44 -0400
In-Reply-To: <20070614231223.GZ4397@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> Replace literal with const; add bit definitions.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> 
> ----
> 
> On Wed, Jun 13, 2007 at 04:12:00PM -0400, Jeff Garzik wrote:
>> A follow-up patch needs to remove the above magic numbers (==numeric 
>> constants), replacing them with named constants
> 
> Here it is. Lightly stres-tested (about 1/2 hour), as this patch
> tests some additonal bits.
> 
>  drivers/net/spider_net.c |    2 +-
>  drivers/net/spider_net.h |   19 +++++++++++++++++++
>  2 files changed, 20 insertions(+), 1 deletion(-)

applied to #upstream (2.6.23)


