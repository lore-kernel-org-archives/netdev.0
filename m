From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT v4 PATCH 4/5] DCB: Add interface to query the state
 of PFC feature.
Date: Thu, 20 Nov 2008 21:09:37 -0800 (PST)
Message-ID: <20081120.210937.236782441.davem@davemloft.net>
References: <20081121020055.22180.24154.stgit@gitlost.lost>
	<20081121020159.22180.92029.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43630
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753210AbYKUFJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 00:09:37 -0500
In-Reply-To: <20081121020159.22180.92029.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 20 Nov 2008 18:01:59 -0800

> Adds a netlink interface for Data Center Bridging (DCB) to get and
> set the enable state of the Priority Flow Control (PFC) feature.
> Primarily, this is a way to turn off PFC in the driver while DCB
> remains enabled.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Applied.
