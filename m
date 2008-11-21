From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT v4 PATCH 1/5] ixgbe: this patch adds support for DCB
 to the kernel and ixgbe driver
Date: Thu, 20 Nov 2008 21:02:39 -0800 (PST)
Message-ID: <20081120.210239.215795673.davem@davemloft.net>
References: <20081121020055.22180.24154.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33751
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750835AbYKUFCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 00:02:39 -0500
In-Reply-To: <20081121020055.22180.24154.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 20 Nov 2008 18:00:55 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
>
> This adds support for Data Center Bridging (DCB) features in the
> ixgbe driver and adds an rtnetlink interface for configuring DCB to
> the kernel.  The DCB feature support included are Priority Grouping
> (PG) - which allows bandwidth guarantees to be allocated to groups
> to traffic based on the 802.1q priority, and Priority Based Flow
> Control (PFC) - which introduces a new MAC control PAUSE frame which
> works at granularity of the 802.1p priority instead of the link
> (IEEE 802.3x).
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Applied.
