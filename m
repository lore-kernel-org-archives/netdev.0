From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT v4 PATCH 3/5] DCB: Add interface to query # of TCs
 supported by device
Date: Thu, 20 Nov 2008 21:08:34 -0800 (PST)
Message-ID: <20081120.210834.243812888.davem@davemloft.net>
References: <20081121020055.22180.24154.stgit@gitlost.lost>
	<20081121020138.22180.60325.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43626
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751075AbYKUFIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 00:08:34 -0500
In-Reply-To: <20081121020138.22180.60325.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 20 Nov 2008 18:01:39 -0800

> Adds interface for Data Center Bridging (DCB) to query (and set if
> supported) the number of traffic classes currently supported by the
> device for the two (DCB) features: priority groups (PG) and priority
> flow control (PFC).
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Applied.
