From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 plans
Date: Wed, 19 Sep 2007 15:19:28 -0700 (PDT)
Message-ID: <20070919.151928.122833514.davem@davemloft.net>
References: <20070918032328.GB3875@tuxdriver.com>
	<20070919012752.GA3717@tuxdriver.com>
	<20070919210700.GF5483@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49248
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750868AbXISWT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 18:19:28 -0400
In-Reply-To: <20070919210700.GF5483@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 19 Sep 2007 17:07:00 -0400

> And the latest incarnation:
> 
> 	http://www.kernel.org/pub/linux/kernel/people/linville/git-wireless-2007-09-19-16-57-43-0500.patch
> 
> And is even smaller...down an additional 30%, or almost 1/6th of the
> original! :-)

Yes, great progress, thanks John :-)

So it looks like what's left is:

1) ATH5K driver
2) ATMEL USB driver
3) NL80211
4) misc bits sprinkled around mac80211
