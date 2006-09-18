From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] please include in 2.6.18: e100 disable device on PCI error
Date: Mon, 18 Sep 2006 16:09:45 -0500
Message-ID: <20060918210945.GF29167@austin.ibm.com>
References: <20060918200122.GD29167@austin.ibm.com> <20060918132102.d850c1c2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Rajesh Shah <rajesh.shah@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"bibo,mao" <bibo.mao@intel.com>, Auke Kok <sofar@foo-projects.org>,
	Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:29352 "EHLO
	e32.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751183AbWIRVJq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 17:09:46 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060918132102.d850c1c2.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It seems our mails crossed.

On Mon, Sep 18, 2006 at 01:21:02PM -0700, Andrew Morton wrote:
> 
> hm.  I don't have this patch queued, but I _do_ have an equivalent patch
> for e1000 queued; what's up with that?  Nobody seems to have paid much
> attention to the e1000 fix.

I spotted the e100 patch in your "broken-out" patches earlier today, 
as a part of "git-netdev-all.patch" (where it had the right changelog 
and old acks)

> If we can gather the appropriate acks quickly then I expect we can get both
> of these into 2.6.18.

That would be great! Thanks.

--linas
