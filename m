From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Ensure that we unshare skbs prior to calling
 pskb_may_pull in bonding driver
Date: Fri, 21 Jan 2011 06:51:05 -0500
Message-ID: <20110121115105.GA30868@hmsreliant.think-freely.org>
References: <1295550151-25913-1-git-send-email-nhorman@tuxdriver.com>
 <20110120.164723.73670910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51549 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126Ab1AULvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 06:51:16 -0500
Content-Disposition: inline
In-Reply-To: <20110120.164723.73670910.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 20, 2011 at 04:47:23PM -0800, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Thu, 20 Jan 2011 14:02:31 -0500
> 
> > Recently reported oops:
> 
> Applied, but please compose reasonable Subject lines with your patches,
> always begin the line with a subsystem tag followed by a colon.
> 
> This way we get
> 
> 	bonding: Foo bar baz
> 
> instead of
> 
> 	Foo bar baz in the bonding driver
> 
> Thanks.
> 
Yeah, my bad, I realized I screwed up the Subject the second I sent the email,
sorry about that.

Regards
Neil

