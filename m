From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 8/15] spidernet: beautify error messages
Date: Wed, 13 Jun 2007 16:15:54 -0400
Message-ID: <4670507A.3040800@garzik.org>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com> <20070611184138.GH13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39315 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751685AbXFMUP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 16:15:57 -0400
In-Reply-To: <20070611184138.GH13741@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> Use dev_err() to print device error messages.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> 
> ----
>  drivers/net/spider_net.c |   64 ++++++++++++++++++++++++-----------------------
>  1 file changed, 34 insertions(+), 30 deletions(-)

applied 8-11, 13-15 to #upstream (2.6.23)


