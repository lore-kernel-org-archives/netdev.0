From: David Miller <davem@davemloft.net>
Subject: net-next-2.6 status...
Date: Tue, 15 Mar 2011 16:01:24 -0700 (PDT)
Message-ID: <20110315.160124.104058374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netfilter-devel@vger.kernel.org,
	eric.dumazet@vger.kernel.org, jpirko@redhat.com,
	linville@tuxdriver.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38591
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751116Ab1COXAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 19:00:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please do not submit feature patches until the merge window is over and
Linus releases 2.6.39-rc1, thank you.

Bug fixes are, of course, still ok.

I have merged all of the stragglers from net-2.6 that didn't make it
into 2.6.38 into net-next-2.6, and also just about everything that
is relevant from patchwork.

Jiri, I know there is your patch set there, but I think you and Changli
still need to go back and forth one more time wrt. orig_dev semantics.
Since you have been posting this patch set for some time I'm still
willing to apply it for this merge window, but please make haste and
work out the remaining discussion.  Thank you.

Eric, I'd like to have the ECN one-liner in the tree soon.

John and Patrick, I assume that after today's pulls I am completely
up to date with everything, feature wise, that will go into the merge
window for wireless and netfilter.

Thanks.
