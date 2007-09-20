From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: net-2.6.24 plans
Date: Thu, 20 Sep 2007 12:56:34 -0400
Message-ID: <20070920165634.GG6748@tuxdriver.com>
References: <20070918032328.GB3875@tuxdriver.com> <20070919012752.GA3717@tuxdriver.com> <20070919210700.GF5483@tuxdriver.com> <20070919.151928.122833514.davem@davemloft.net> <20070920141723.GE6748@tuxdriver.com> <1190299852.18521.71.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, jgarzik@pobox.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4961 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757210AbXITRIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 13:08:25 -0400
Content-Disposition: inline
In-Reply-To: <1190299852.18521.71.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 20, 2007 at 04:50:52PM +0200, Johannes Berg wrote:
> On Thu, 2007-09-20 at 10:17 -0400, John W. Linville wrote:
> 
> > > 2) ATMEL USB driver
> > 
> > These are both really new.  I think I'll transfer them to my
> > wireless-2.6 tree, but still hold them back at least until 2.6.25.
> 
> Also, atmel isn't even ported to mac80211 yet, is it?

Kalle Valo has done some work on this, and I think Eugene Teo has
joined the effort.  They both are in contact with Pavel to accomplish
the mac80211 port.

John
-- 
John W. Linville
linville@tuxdriver.com
