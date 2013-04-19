From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net 0/3] qlge: Bug fixes
Date: Fri, 19 Apr 2013 01:49:51 -0400
Message-ID: <1366350594-21973-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:20013 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754039Ab3DSGNo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 02:13:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Please apply to net

Thanks,
   Jiten

Jitendra Kalsaria (2):
  qlge: Fix ethtool autoneg advertising.
  qlge: Update version to 1.00.00.32.

Sritej Velaga (1):
  qlge: Fix receive path to drop error frames

 drivers/net/ethernet/qlogic/qlge/qlge.h         |    2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c |    2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c    |   36 ++++++++++++++++++----
 3 files changed, 31 insertions(+), 9 deletions(-)

-- 
1.7.6.rc1.1.g2c162b
