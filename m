From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 00/17] mlx4_en: driver updates
Date: Mon, 7 Mar 2011 12:16:50 +0200
Message-ID: <4D74B092.5010408@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:40246 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751650Ab1CGKQz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 05:16:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello David,

This patch set presents a set of fixes, performance improvements and new features for the mlx4_core and mlx4_en modules.
main changes are:
- MSI-X per ring
- Changing RX packet steering model for supported devices
- BlueFlame support for better TX latency.
- Adaptive moderation improvements.

Patches were generated against net-next-2.6.git

Thanks,
Yevgeny
