From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT v4 PATCH 5/5] DCB: Add support for DCB BCN
Date: Thu, 20 Nov 2008 21:10:33 -0800 (PST)
Message-ID: <20081120.211033.193114646.davem@davemloft.net>
References: <20081121020055.22180.24154.stgit@gitlost.lost>
	<20081121020220.22180.58962.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43634
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751641AbYKUFKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 00:10:33 -0500
In-Reply-To: <20081121020220.22180.58962.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 20 Nov 2008 18:02:20 -0800

> Adds an interface to configure the Backward Congestion Notification
> (BCN) feature.  In a BCN capabale network, congestion notifications
> from congested points out in the network can cause the end station
> limit the rate of a given traffic flow.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Applied.
