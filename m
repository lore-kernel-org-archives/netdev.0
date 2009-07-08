From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8 net-next-2.6] cxgb3: driver update
Date: Wed, 08 Jul 2009 10:56:06 -0700 (PDT)
Message-ID: <20090708.105606.227710373.davem@davemloft.net>
References: <4A54332D.3010102@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758093AbZGHR4M@vger.kernel.org>
In-Reply-To: <4A54332D.3010102@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>
Date: Tue, 07 Jul 2009 22:48:29 -0700

> I am submitting a series of 8 patches for inclusion in net-next-2.6.
> Here is a brief description of the patch series:
> - Drain the mac Tx fifo when a port goes down
> - Fix the mac high water computation on T3C chips
> - Fix LED settings and first link status report for the AEL2020 phy
> - Minor fixes to the AQ100X phy
> - Toggles Global Tx disable bit on phys when powered down
> - Fix HW initialization for offload connections
> - Fix MAC indexation for the Gen2 adapter
> - use request_firmware() to load the phy EDC programming.

Looks good, all applied.

Thanks for taking care of the request_firmware() issue.
