From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: net-2.6.24 rebased
Date: Fri, 31 Aug 2007 09:44:32 -0400
Message-ID: <20070831134432.GA3352@tuxdriver.com>
References: <1188431227.6062.114.camel@localhost> <1188454772.6062.134.camel@localhost> <1188475093.2963.13.camel@johannes.berg> <20070830.222129.102575067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3158 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965109AbXHaOPV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 10:15:21 -0400
Content-Disposition: inline
In-Reply-To: <20070830.222129.102575067.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 30, 2007 at 10:21:29PM -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Thu, 30 Aug 2007 13:58:12 +0200
> 
> > Huh? I'm fairly sure I sent a patch to remove it from that driver, no
> > idea where it got lost. FWIW, you can simply delete the "|
> > IEEE80211_HW_DATA_NULLFUNC_ACK" part.
> 
> It might have been a mis-merge between John and myself.
> A few times because I had rebased I had to take his
> directory of patches and one of us might have made a
> mistake somewhere along the line.
> 
> In any event, I've removed the offending line from
> the driver.

Sorry, I sent the patch through Jeff.

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-jgarzik/0010-rtl8187-remove-IEEE80211_HW_DATA_NULLFUNC_ACK.patch

But, it sounds like you have taken care of it...?

Let me know if I need to fix this.

John
-- 
John W. Linville
linville@tuxdriver.com
