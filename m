From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] bcm43xx-d80211: proper implementation of virtual
 interface support
Date: Fri, 5 May 2006 12:34:15 +0200
Message-ID: <20060505123415.42c3d4d1@griffin.suse.cz>
References: <200605012135.00895.mb@bu3sch.de>
	<20060502132037.059a7cb2@griffin.suse.cz>
	<e3dkfd$pc5$1@sea.gmane.org>
	<200605042256.02333.IvDoorn@gmail.com>
	<20060505002215.1972e12b@logostar.upir.cz>
	<Pine.LNX.4.58.0605050738240.21178@p15091797.pureserver.info>
	<1146824140.1137.67.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ulrich Kunitz <kune@deine-taler.de>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Marcus Better <marcus@better.se>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:59295 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751516AbWEEKeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 06:34:17 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1146824140.1137.67.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 05 May 2006 12:15:40 +0200, Johannes Berg wrote:
> On Fri, 2006-05-05 at 07:45 +0200, Ulrich Kunitz wrote:
> >  But there could be also
> > support for one interface in AP and the other in STA mode.
> 
> That's actually a much more interesting use case for WDS.

You don't need different MAC address for WDS.

 Jiri

-- 
Jiri Benc
SUSE Labs
