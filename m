From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT v2 PATCH] ixgbe: add SFP+ driver support
Date: Thu, 20 Nov 2008 21:11:53 -0800 (PST)
Message-ID: <20081120.211153.143839944.davem@davemloft.net>
References: <20081121020321.22288.16876.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	donald.c.skidmore@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43639
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752338AbYKUFLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 00:11:53 -0500
In-Reply-To: <20081121020321.22288.16876.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 20 Nov 2008 18:03:21 -0800

> This patch adds support for SFP+ PHY in the following device ID's (10DB,
> 10F1, 10E1).  These SFP+ PHY's are accessed via an I2C interface so the
> patch also includes functions to support this.
> 
> Another feature of note is that the PHY is pluggable and some
> rearchitecting was needed to support this.
> 
> Signed-off-by: Donald Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
