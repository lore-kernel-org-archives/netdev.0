From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 02/14] e1000e: commit speed/duplex changes for
 m88 PHY
Date: Fri, 21 Nov 2008 16:50:02 -0800 (PST)
Message-ID: <20081121.165002.05610225.davem@davemloft.net>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
	<20081121185922.32313.24916.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36963
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757569AbYKVAuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:50:03 -0500
In-Reply-To: <20081121185922.32313.24916.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2008 10:59:22 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Follow the convention used elsewhere in e1000e to 'commit' PHY changes
> instead of directly writing to the PHY CTRL register to reset it.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
