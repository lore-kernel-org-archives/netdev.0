From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 0/7] sky2 version 1.15 (88e8071) support
Date: Mon, 04 Jun 2007 17:23:20 -0700
Message-ID: <20070605002320.868185090@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60034 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752697AbXFEAnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 20:43:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These changes are to enable the Yukon Extreme (88e8071)
chipset. This chip is similar to earlier chip but has a different
set of offloading operations and some other minor quirks.

Marvell has given me some evaluation boards with the 88e8071
chip set. The chip is available now, but haven't seen a systems
with the hardware yet. The support fot this is exprerimental
at this point, but haven't encountered any new problems.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

