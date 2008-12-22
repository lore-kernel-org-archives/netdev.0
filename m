From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 3/3] ixgbe: fix the display of DCB control
 stats in ethtool
Date: Sun, 21 Dec 2008 20:11:15 -0800 (PST)
Message-ID: <20081221.201115.85751859.davem@davemloft.net>
References: <20081220001438.5908.23307.stgit@lost.foo-projects.org>
	<20081220001520.5908.65998.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	donald.c.skidmore@intel.com, eric.w.multanen@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43155
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752626AbYLVELN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 23:11:13 -0500
In-Reply-To: <20081220001520.5908.65998.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 19 Dec 2008 16:15:20 -0800

> Priority flow contol statistics for Data Center Bridging (DCB) weren't
> included in ethtool.  This patch adds them.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Eric W Multanen <eric.w.multanen@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Also applied, thanks.
