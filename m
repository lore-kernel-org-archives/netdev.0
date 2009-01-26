From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: fix function prototype of async callback
Date: Sun, 25 Jan 2009 17:54:58 -0800 (PST)
Message-ID: <20090125.175458.70126165.davem@davemloft.net>
References: <1232464140-27713-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com, oliver@neukum.org
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45576
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751107AbZAZBy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2009 20:54:56 -0500
In-Reply-To: <1232464140-27713-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Tue, 20 Jan 2009 15:09:00 +0000

> smsc95xx_async_cmd_callback doesn't currently match usb_complete_t, so
> there's a cast to force the square peg into the round hole.  This patch
> fixes this properly.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied.
