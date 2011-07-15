From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next-2.6 2011-07-15
Date: Fri, 15 Jul 2011 08:54:46 -0700 (PDT)
Message-ID: <20110715.085446.1466613576048740142.davem@davemloft.net>
References: <20110715153435.GA2566@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57286 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111Ab1GOPzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 11:55:55 -0400
In-Reply-To: <20110715153435.GA2566@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 15 Jul 2011 11:34:36 -0400

> Here is yet another batch of wireless networking changes intended
> for 3.1, with probably a smidge more yet to come... :-)
> 
> This includes another Bluetooth pull, mostly some cleanups,
> restructuring, and some minor fixes.  Along with the usual iwlagn and
> ath9k updates, mwifiex, wl12xx, ath5k, and b43 all see significant
> activity.  Johannes has done some housekeeping in mac80211 as well.
> 
> Please let me know if there are problems!

Pulled, thanks John.

It seems we have one more bluetooth regression straggler for
3.0.0, please make sure I get that soon otherwise it might
not make it in time:

http://marc.info/?l=linux-kernel&m=131072468622609&w=2

Thanks.
