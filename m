From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/4] ixgbe: Disable Flow Control for
 certain devices
Date: Sun, 29 Nov 2009 00:34:47 -0800 (PST)
Message-ID: <20091129.003447.15610689.davem@davemloft.net>
References: <20091125045059.23932.10997.stgit@localhost.localdomain>
	<20091125045127.23932.79040.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37183
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753267AbZK2Iem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 03:34:42 -0500
In-Reply-To: <20091125045127.23932.79040.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 24 Nov 2009 20:51:28 -0800

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> Flow Control autoneg should be disabled for certain adapters
> that don't support autonegotiation of Flow Control at 10 gigabit.
> These interfaces are the 10GBASE-T devices, CX4, and SFP+, all
> running at 10 gigabit only.  1 gigabit is fine.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
