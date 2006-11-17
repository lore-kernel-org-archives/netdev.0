From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.20 0/17][BNX2]: patches
Date: Thu, 16 Nov 2006 18:58:53 -0800
Message-ID: <1163732333.6658.22.camel@rh4>
References: <1163731443.6658.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:16906 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1424905AbWKQCGb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 21:06:31 -0500
To: davem@davemloft.net
In-Reply-To: <1163731443.6658.8.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,  A set of BNX2 patches for 2.6.20 to fix bugs, improve
SerDes, and support a new chip.  Please review and apply.

Thanks.

[PATCH 1/17][BNX2]: Fix Xen problem.
[PATCH 2/17][BNX2]: Improve SerDes handling.
[PATCH 3/17][BNX2]: Add bnx2_5706_serdes_timer().
[PATCH 4/17][BNX2]: Add 5708S parallel detection.
[PATCH 5/17][BNX2]: Remove udelay() in copper PHY code.
[PATCH 6/17][BNX2]: Re-organize firmware structures.
[PATCH 7/17][BNX2]: Add new 5709 registers (part 1).
[PATCH 8/17][BNX2]: Add new 5709 registers (part 2).
[PATCH 9/17][BNX2]: Add 5709 init code.
[PATCH 10/17][BNX2]: Add 5709 reset and runtime code.
[PATCH 11/17][BNX2]: New firmware to support 5709 (part 1).
[PATCH 12/17][BNX2]: New firmware to support 5709 (part 2).
[PATCH 13/17][BNX2]: New firmware to support 5709 (part 3).
[PATCH 14/17][BNX2]: New firmware to support 5709 (part 4).
[PATCH 15/17][BNX2]: Download 5709 firmware.
[PATCH 16/17][BNX2]: Add 5709 PCI ID.
[PATCH 17/17][BNX2]: Update version and rel date.


