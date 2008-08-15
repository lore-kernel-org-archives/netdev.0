From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for
 iptables nat routing
Date: Fri, 15 Aug 2008 14:55:32 -0700 (PDT)
Message-ID: <20080815.145532.145160495.davem@davemloft.net>
References: <20080815103235.GA31963@gondor.apana.org.au>
	<20080815105318.GA5590@gondor.apana.org.au>
	<1218814487.23510.28.camel@2710p.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kaber@trash.net,
	akpm@linux-foundation.org, buytenh@marvell.com,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: alex.williamson@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54110
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755191AbYHOVzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 17:55:32 -0400
In-Reply-To: <1218814487.23510.28.camel@2710p.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 15 Aug 2008 09:34:47 -0600

> On Fri, 2008-08-15 at 20:53 +1000, Herbert Xu wrote:
> > On Fri, Aug 15, 2008 at 08:32:35PM +1000, Herbert Xu wrote:
> > > 
> > > I'll work on the netfilter state preservation next.
> > 
> > Here it is:
> 
> Confirmed, these patches solve the problem.  Thanks Herbert.

Thanks for your report and testing the fix Alex.
