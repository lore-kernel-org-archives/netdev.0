From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 00/10] convert arm platforms to smsc911x
Date: Sun, 01 Feb 2009 00:38:24 -0800 (PST)
Message-ID: <20090201.003824.20277745.davem@davemloft.net>
References: <1233075077-17205-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	linux@arm.linux.org.uk, stanley.miao@windriver.com,
	ian.saturley@smsc.com, broonie@opensource.wolfsonmicro.com,
	catalin.marinas@arm.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52754
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751661AbZBAIi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 03:38:28 -0500
In-Reply-To: <1233075077-17205-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Tue, 27 Jan 2009 16:51:08 +0000

> This patchset, intended for 2.6.30, converts in-tree arm platforms from
> smc911x to the actively maintained smsc911x driver.
> 
> The platform updates (5-7) depend on the driver updates (1-4) for 
> correct operation, so David Miller is planning to take these via the 
> net-2.6 tree.  Defconfig updates have been split out (8-10) for merging 
> via the arm tree.

I've applied patches 1-4 to net-next-2.6, thanks a lot Steve!
