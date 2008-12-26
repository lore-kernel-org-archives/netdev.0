From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] smsc911x: don't clobber driver_data
Date: Thu, 25 Dec 2008 16:43:43 -0800 (PST)
Message-ID: <20081225.164343.73044608.davem@davemloft.net>
References: <1229709930-19925-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dfoley@telus.net, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56000
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752173AbYLZAnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 19:43:40 -0500
In-Reply-To: <1229709930-19925-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Fri, 19 Dec 2008 18:05:29 +0000

> smsc911x uses driver_data to store our net_device, don't overwrite this
> with the mii_bus.
> 
> Reported and fixed by dfoley@telus.net.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied.
