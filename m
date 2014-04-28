From: clsoto@linux.vnet.ibm.com
Subject: [PATCH 0/1] mlx4: mlx4_core failed to load
Date: Mon, 28 Apr 2014 13:33:30 -0500
Message-ID: <20140428183330.201681971@linux.vnet.ibm.com>
Cc: clsoto@linux.vnet.ibm.com, brking@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [32.97.110.57] ([32.97.110.57]:32926 "HELO
	jupiter1-lp2.austin.ibm.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S933028AbaD1Tb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:31:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is for a case where mlx4_core fails to load.

 drivers/net/ethernet/mellanox/mlx4/main.c |    7 -------
 include/linux/mlx4/device.h               |    1 -
 2 files changed, 8 deletions(-)

Carol

-- 
