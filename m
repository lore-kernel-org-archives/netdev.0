From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH v2 00/16] mlx4_en: driver updates
Date: Wed, 23 Mar 2011 10:37:15 +0200
Message-ID: <4D89B13B.2010404@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:58008 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752187Ab1CWIhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 04:37:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

This is the second round for patches originally sent on March 07.

Changes from previous round (after getting the feedbacks):
1. Renamed IRQ name for TX rings.
2. Changed error message when failing to map BlueFlame area.
3. Removed drivers/infiniband/hw/mlx4/ parts of steering changes, those need to be applied with Raw QP support.

Thanks,
Yevgeny

