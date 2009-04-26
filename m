From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next-2.6 2009-04-24
Date: Sat, 25 Apr 2009 17:45:49 -0700 (PDT)
Message-ID: <20090425.174549.207994669.davem@davemloft.net>
References: <20090424200504.GC3309@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48803
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752169AbZDZAp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2009 20:45:56 -0400
In-Reply-To: <20090424200504.GC3309@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 24 Apr 2009 16:05:05 -0400

> Here is a huge pull request for net-next-2.6, the first one this
> cycle.  There is the usual huge round of driver and mac80211 updates.
> Among other things is some movement of code to enable sharing some bits
> between ath5k, ath9k, and ar9170.  Also included is the beginngin of
> migration of rndis_wlan to the cfg80211 API, the first non-mac80211
> driver to do that.
> 
> Please let me know if there are problems!

Since I had pulled net-2.6 into net-next-2.6, aparently after you
built this tree, there was a conflict to deal with in net/mac80211/pm.c

I hope I got it right ;-)

Pulled, thanks a lot!
