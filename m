From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT v2 PATCH] ixgbe: Implement PCIe AER support
Date: Wed, 10 Dec 2008 01:14:47 -0800 (PST)
Message-ID: <20081210.011447.135553163.davem@davemloft.net>
References: <20081210024423.27657.32266.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48476
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753141AbYLJJOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 04:14:47 -0500
In-Reply-To: <20081210024423.27657.32266.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 09 Dec 2008 18:44:23 -0800

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> This patch implements the PCIe Advanced Error Reporting callbacks in
> ixgbe.  The 82598 hardware supports AER, so we enable it.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
