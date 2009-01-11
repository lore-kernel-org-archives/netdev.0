From: David Miller <davem@davemloft.net>
Subject: decisions, decisions...
Date: Sat, 10 Jan 2009 23:51:41 -0800 (PST)
Message-ID: <20090110.235141.223618374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59255
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751189AbZAKHvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 02:51:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, the merge window is closed.

So I'm going to rework the net-2.6 tree do that only bug fixes and
-RCx material remains in there.  In particular the latest batch
of net_dev_ops conversions are getting pulled out.

I'm going to put those removed changes aside somewhere locally, and I
will not push them into net-next-2.6 until Stephen Rothwell gives the
OK for that kind of stuff showing up in -next.

The merge window was 2 weeks long, so no complaints from anyone
please.

I'm particularly disappointed that I haven't seen one pull request for
wireless pretty much the entire 2 week period.  What were you guys
doing, baking gingerbread cookies the entire time?  :-))))
