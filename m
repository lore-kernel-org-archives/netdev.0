From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/3] cxgb - driver fixes.
Date: Tue, 27 Nov 2007 13:28:24 -0800
Message-ID: <474C8BF8.9080609@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>
To: Jeff Garzik <jeff@garzik.org>, NetDev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:12701 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757588AbXK0V2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 16:28:31 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

I'm submitting a patch series for inclusion in 2.6.24 for the cxgb driver.
The patches are built against Linus'git tree.

Here is a brief description:
- Ensure that GSO skbs have enough headroom before encapsulating them,
- Fix a crash in NAPI mode,
- Fix statistics accounting and report.

Cheers,
Divy


