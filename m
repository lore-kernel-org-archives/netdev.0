From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: net-2.6.24 plans
Date: Thu, 20 Sep 2007 10:17:23 -0400
Message-ID: <20070920141723.GE6748@tuxdriver.com>
References: <20070918032328.GB3875@tuxdriver.com> <20070919012752.GA3717@tuxdriver.com> <20070919210700.GF5483@tuxdriver.com> <20070919.151928.122833514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4102 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147AbXITOpD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 10:45:03 -0400
Content-Disposition: inline
In-Reply-To: <20070919.151928.122833514.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 03:19:28PM -0700, David Miller wrote:

> So it looks like what's left is:
> 
> 1) ATH5K driver
> 2) ATMEL USB driver

These are both really new.  I think I'll transfer them to my
wireless-2.6 tree, but still hold them back at least until 2.6.25.

> 3) NL80211

I need to check w/ Johannes to see if the user-facing portions of
this have stabilized.

> 4) misc bits sprinkled around mac80211

These bits are mostly pieces with unsettled user inferface issues
or unsettled features that still need some development.  I'll be
holding-on to these a while longer.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
