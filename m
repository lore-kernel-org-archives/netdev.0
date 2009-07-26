From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next-2.6 2009-07-24
Date: Sun, 26 Jul 2009 10:02:14 -0700 (PDT)
Message-ID: <20090726.100214.125172881.davem@davemloft.net>
References: <20090724193625.GB2711@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47587
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753840AbZGZRCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 13:02:08 -0400
In-Reply-To: <20090724193625.GB2711@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 24 Jul 2009 15:36:25 -0400

> Here is the latest huge round of wireless patches intended for 2.6.32.
> It hits all the usual areas (i.e. drivers, mac80211, and cfg80211) with
> patches from all the usual suspects.  This includes the reworking of
> mac80211 to eliminate the confusing "master netdev".
> 
> FWIW, my laptop has been happy with it.  Most of the bits here have been
> in -next for at least a few days.
> 
> Please let me know if there are problems!

Pulled, thanks a lot John!

Please try to resolve the regression reports that I saw posted against
wireless-testing on the same day you sent this pull request.
