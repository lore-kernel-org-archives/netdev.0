From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/10] ixgbe: Update the usage of orig_autoc to be more
 consistent
Date: Sat, 11 Apr 2009 02:51:16 -0700 (PDT)
Message-ID: <20090411.025116.215962051.davem@davemloft.net>
References: <20090410082618.14372.86091.stgit@localhost.localdomain>
	<20090410082832.14372.72843.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58393
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757616AbZDKJvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 05:51:25 -0400
In-Reply-To: <20090410082832.14372.72843.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 10 Apr 2009 01:28:33 -0700

> The orig_autoc variable tracks the original setting of the autonegotiate
> state prior to trying a new speed.  The usage is inconsistent and not very
> maintainable.  This patch updates the usage to make it more consistent.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied to net-next-2.6
