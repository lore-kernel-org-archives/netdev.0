From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/15] spidernet driver bug fixes
Date: Tue, 12 Jun 2007 21:54:44 -0400
Message-ID: <466F4E64.5070303@garzik.org>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com>  <466F2581.2080808@garzik.org> <1181698396.6988.5.camel@concordia.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: michael@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60031 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755145AbXFMByt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 21:54:49 -0400
In-Reply-To: <1181698396.6988.5.camel@concordia.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Ellerman wrote:
> Linas posted the patches, I responded querying whether the bug fixes
> should go into 2.6.22, and then you told him "you need to order your bug
> fixes first in the queue". Which seemed pretty clear to me that you'd
> wait for the reordered series.

This was presuming Linas actually knew what he himself had submitted 
previously, and had been accepted...

I explicitly emailed Linas on May 24, 2007 detailing each patch that had 
been applied, and to which netdev-2.6.git branch it had been applied 
(and thus whether it was queued for 2.6.22 or 2.6.23).  Relevant 
Message-id is <4656033F.1060505@garzik.org>, and was sent not only to 
Linas but also to netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, and 
cbe-oss-dev@ozlabs.org.

These changes were subsequently made public immediately via 
git://git.kernel.org/.../jgarzik/netdev-2.6.git branches 
'upstream-fixes' and 'upstream', and were followed a few days later by 
akpm's public tree, starting with 2.6.22-rc3-mm1 (and all subsequent 
releases).

All of the above seemed pretty clear, too.

To move forward, it sounds like the best thing to do is drop all 
spidernet patches and start over, yes?

	Jeff


