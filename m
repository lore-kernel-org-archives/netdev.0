From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [FIX] e1000: fix irq sharing when running ethtool test
Date: Fri, 2 Jun 2006 18:22:29 -0400
Message-ID: <20060602222229.GA24528@havoc.gtf.org>
References: <4480B983.50702@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:10141 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S932580AbWFBW2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 18:28:22 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
Content-Disposition: inline
In-Reply-To: <4480B983.50702@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 02, 2006 at 03:19:47PM -0700, Auke Kok wrote:
> Because upstream and upstream-fixes have a whitespace conflict in them, 
> I've prepared two separate git branches to pull from so that a subsequent 
> pull or merge from upstream-fixes into upstream doesn't resolve into a 
> conflict:

That won't work, because it creates duplicate changesets in the history.

I'll pull the upstream-fixes version, and then merge into #upstream.

	Jeff



