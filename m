From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 rebased
Date: Thu, 30 Aug 2007 22:21:29 -0700 (PDT)
Message-ID: <20070830.222129.102575067.davem@davemloft.net>
References: <1188431227.6062.114.camel@localhost>
	<1188454772.6062.134.camel@localhost>
	<1188475093.2963.13.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, linville@tuxdriver.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59474
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754564AbXHaFVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 01:21:31 -0400
In-Reply-To: <1188475093.2963.13.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 30 Aug 2007 13:58:12 +0200

> Huh? I'm fairly sure I sent a patch to remove it from that driver, no
> idea where it got lost. FWIW, you can simply delete the "|
> IEEE80211_HW_DATA_NULLFUNC_ACK" part.

It might have been a mis-merge between John and myself.
A few times because I had rebased I had to take his
directory of patches and one of us might have made a
mistake somewhere along the line.

In any event, I've removed the offending line from
the driver.
