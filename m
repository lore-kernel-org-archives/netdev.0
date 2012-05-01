From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] smsc75xx fixes
Date: Mon, 30 Apr 2012 21:55:23 -0400 (EDT)
Message-ID: <20120430.215523.1287471552904931575.davem@davemloft.net>
References: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fillods@users.sf.net
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45014 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234Ab2EABze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 21:55:34 -0400
In-Reply-To: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Mon, 30 Apr 2012 18:56:49 +0100

> Stephane Fillod's big patch addresses multiple issues, so this patchset
> splits it into a separate patch for each issue.
> 
> Thanks to Stephane for finding and fixing these bugs.
> 
> Steve Glendinning (7):
>   smsc75xx: mark link down on startup and let PHY interrupt deal with
>     carrier changes
>   smsc75xx: fix mdio reads and writes
>   smsc75xx: add more information to register io failure warnings
>   smsc75xx: fix phy init reset loop
>   smsc75xx: fix phy interrupt acknowledge
>   smsc75xx: declare smsc75xx's MII as GMII capable
>   smsc75xx: enable mac to detect speed/duplex from phy

All applied, thanks Steve.
