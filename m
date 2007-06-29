From: Jason Lunz <lunz@reflexsecurity.com>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 10:50:07 -0700
Message-ID: <20070629175006.GB3917@falooley.org>
References: <1183138159.17243.16.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crown.reflexsecurity.com ([72.54.139.163]:47034 "EHLO
	crown.reflexsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753508AbXF2Rt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 13:49:56 -0400
Content-Disposition: inline
In-Reply-To: <1183138159.17243.16.camel@blaa>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 29, 2007 at 06:29:18PM +0100, Mark McLoughlin wrote:
> 	I understand there is some delay in getting e1000-7.5.5 into the
> upstream kernel given the major re-working of the chipset specific
> parts.
> 
> 	I wonder would it be feasible in the meantime to backport the ich9
> support and push it upstream?

seconded - this driver reorg has been holding back support for the
newest e1000 hardware since at least 2.6.20, and I haven't seen any
indication that the 7.5.5 e1000 driver will even be added to 2.6.23.

What's the prognosis for the 7.5.5-series e1000 reorg going into
netdev-2.6?

Jason
