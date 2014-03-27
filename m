From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH 0/2] Adds new device ID for Chelsio Adapters
Date: Thu, 27 Mar 2014 18:17:08 +0530
Message-ID: <1395924430-17632-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	kumaras@chelsio.com, santosh@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12762 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753943AbaC0Mz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 08:55:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series adds device ID for a couple of Chelsio Adapters for both
cxgb4 and cxgb4vf driver.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (2):
  cxgb4: Adds device ID for few more Chelsio Adapters
  cxgb4vf: Adds device Id for few more Chelsio adapters

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     | 12 ++++++++++++
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c |  8 ++++++++
 2 files changed, 20 insertions(+)

-- 
1.8.4
