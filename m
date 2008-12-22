From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 2/3] net: add DCNA attribute to the BCN
 interface for DCB
Date: Sun, 21 Dec 2008 20:10:40 -0800 (PST)
Message-ID: <20081221.201040.115469290.davem@davemloft.net>
References: <20081220001438.5908.23307.stgit@lost.foo-projects.org>
	<20081220001459.5908.13931.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	donald.c.skidmore@intel.com, eric.w.multanen@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43151
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752630AbYLVEKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 23:10:38 -0500
In-Reply-To: <20081220001459.5908.13931.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 19 Dec 2008 16:15:00 -0800

> Adds the Backward Congestion Notification Address (BCNA) attribute to the
> Backward Congestion Notification (BCN) interface for Data Center Bridging
> (DCB), which was missing.  Receive the BCNA attribute in the ixgbe driver.
> The BCNA attribute is for a switch to inform the endstation about the physical
> port identification in order to support BCN on aggregated links.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Eric W Multanen <eric.w.multanen@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
