From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/8 net-next-2.6] cxgb3: driver update
Date: Tue, 07 Jul 2009 22:48:29 -0700
Message-ID: <4A54332D.3010102@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16310 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759526AbZGHF4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 01:56:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I am submitting a series of 8 patches for inclusion in net-next-2.6.
Here is a brief description of the patch series:
- Drain the mac Tx fifo when a port goes down
- Fix the mac high water computation on T3C chips
- Fix LED settings and first link status report for the AEL2020 phy
- Minor fixes to the AQ100X phy
- Toggles Global Tx disable bit on phys when powered down
- Fix HW initialization for offload connections
- Fix MAC indexation for the Gen2 adapter
- use request_firmware() to load the phy EDC programming.

Cheers,
Divy
