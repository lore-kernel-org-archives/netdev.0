From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next 6/8] bna: Add Stats Clear Counter
Date: Thu, 6 Dec 2012 20:54:35 +0000
Message-ID: <1354827275.2828.37.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354748470-26293-1-git-send-email-rmody@brocade.com>
	 <1354748470-26293-7-git-send-email-rmody@brocade.com>
	 <1354760382.17107.140.camel@deadeye.wl.decadent.org.uk>
	 <E5313AF6F2BFD14293E5FD0F94750F86B5B0B9CAF5@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Adapter Linux Open SRC Team
	<adapter_linux_open_src_team@Brocade.COM>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10137 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422867Ab2LFUyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 15:54:38 -0500
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86B5B0B9CAF5@HQ1-EXCH01.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-06 at 12:34 -0800, Rasesh Mody wrote:
> >From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> >Sent: Wednesday, December 05, 2012 6:20 PM
> >Subject: Re: [net-next 6/8] bna: Add Stats Clear Counter
> >
> >On Wed, 2012-12-05 at 15:01 -0800, Rasesh Mody wrote:
> >> Added Stats clear counter to the bfi_enet_stats_mac structure and
> >> ethtool stats
> >>
> >> Signed-off-by: Rasesh Mody <rmody@brocade.com>
> >
> >Since this structure appears to be part of the firmware interface, you
> >should combine this (and any other interface changes) with the change to
> >the requested firmware version (7/8).
> 
> Ben,
> 
> Thanks for the feedback. Yes, bfi_enet_stats_mac is a part of firmware
> interface update.
> 
> In future submission, I will plan to take care of combining such
> firmware interface updates/changes and the firmware request version
> change into single patch. Please let me know if you think it is
> required for this patch set.

That's not my decision.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
