From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2] ixgbe: Update flow control state machine
 in link setup
Date: Fri, 06 Feb 2009 21:47:32 -0800 (PST)
Message-ID: <20090206.214732.53656230.davem@davemloft.net>
References: <20090206224424.28541.494.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44455
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750869AbZBGFrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 00:47:36 -0500
In-Reply-To: <20090206224424.28541.494.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 06 Feb 2009 14:44:26 -0800

> The flow control handling is overly complicated and difficult to maintain.
> This patch cleans up the flow control handling and makes it much more
> explicit.  It also adds 1G flow control autonegotiation, for 1G copper
> links, 1G KX links, and 1G fiber links.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
