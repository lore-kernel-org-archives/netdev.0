From: Wang Jian <lark@linux.net.cn>
Subject: [PATCH 0/2] Fix register misuse in drivers/net/phy/marvel.c
Date: Wed, 16 Jul 2008 21:45:59 +0800
Message-ID: <487DFB97.6010507@linux.net.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexandr Smirnov <asmirnov@ru.mvista.com>,
	Andy Fleming <afleming@freescale.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [210.82.31.146] ([210.82.31.146]:49006 "EHLO mx.linux.net.cn"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754993AbYGPNqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 09:46:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following 2 patches fixed misuse of register for 88e1111. I have
tested the patch 1/2. I have no board to test RGMII mode, patch 2/2 is
obvious but not tested.

I have sent email to Andy but get no response.




