From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH] ixgbe: fix dma mapping unbalance
Date: Mon, 15 Dec 2008 01:01:16 -0800 (PST)
Message-ID: <20081215.010116.144414195.davem@davemloft.net>
References: <20081212095104.4380.49487.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, joerg.roedel@amd.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34723
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752266AbYLOJBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 04:01:15 -0500
In-Reply-To: <20081212095104.4380.49487.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 12 Dec 2008 01:51:05 -0800

> This issue was initially reported by Joerg Roedel <joerg.roedel@amd.com>
> It appears that ixgbe has had a long standing bug where it was unmapping a different size than it had mapped.
 ...
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
