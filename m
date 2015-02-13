From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rhashtable: use rht_obj() consistently
Date: Fri, 13 Feb 2015 21:42:08 +0000
Message-ID: <20150213214208.GB18659@casper.infradead.org>
References: <1423860161-20875-1-git-send-email-johannes@sipsolutions.net>
 <20150213205853.GA18659@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56873 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924AbbBMVmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 16:42:11 -0500
Content-Disposition: inline
In-Reply-To: <20150213205853.GA18659@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/13/15 at 08:58pm, Thomas Graf wrote:
> On 02/13/15 at 09:42pm, Johannes Berg wrote:
> > From: Johannes Berg <johannes.berg@intel.com>
> > 
> > Looking at the RHT code I found two places where this was
> > done manually rather than using the rht_obj() helper, use
> > that instead.
> > 
> > Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>

Actually, this is already "fixed" in net-next.
