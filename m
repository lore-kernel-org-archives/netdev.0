From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.20 0/17][BNX2]: patches
Date: Sun, 19 Nov 2006 17:15:57 -0500 (EST)
Message-ID: <20061119.171557.41650433.davem@davemloft.net>
References: <1163731443.6658.8.camel@rh4>
	<1163732333.6658.22.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:21664 "EHLO localhost")
	by vger.kernel.org with ESMTP id S933458AbWKSWP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Nov 2006 17:15:57 -0500
To: mchan@broadcom.com
In-Reply-To: <1163732333.6658.22.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 16 Nov 2006 18:58:53 -0800

> David,  A set of BNX2 patches for 2.6.20 to fix bugs, improve
> SerDes, and support a new chip.  Please review and apply.
 ...
> [PATCH 1/17][BNX2]: Fix Xen problem.
> [PATCH 2/17][BNX2]: Improve SerDes handling.
> [PATCH 3/17][BNX2]: Add bnx2_5706_serdes_timer().
> [PATCH 4/17][BNX2]: Add 5708S parallel detection.
> [PATCH 5/17][BNX2]: Remove udelay() in copper PHY code.
> [PATCH 6/17][BNX2]: Re-organize firmware structures.
> [PATCH 7/17][BNX2]: Add new 5709 registers (part 1).
> [PATCH 8/17][BNX2]: Add new 5709 registers (part 2).
> [PATCH 9/17][BNX2]: Add 5709 init code.
> [PATCH 10/17][BNX2]: Add 5709 reset and runtime code.
> [PATCH 11/17][BNX2]: New firmware to support 5709 (part 1).
> [PATCH 12/17][BNX2]: New firmware to support 5709 (part 2).
> [PATCH 13/17][BNX2]: New firmware to support 5709 (part 3).
> [PATCH 14/17][BNX2]: New firmware to support 5709 (part 4).
> [PATCH 15/17][BNX2]: Download 5709 firmware.
> [PATCH 16/17][BNX2]: Add 5709 PCI ID.
> [PATCH 17/17][BNX2]: Update version and rel date.

All applied, thanks a lot Michael.
