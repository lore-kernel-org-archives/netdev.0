From: Phil Reid <preid@electromag.com.au>
Subject: [0/1] stmmac: Correctly report PTP capabilities.
Date: Fri, 30 Oct 2015 16:43:54 +0800
Message-ID: <1446194635-19782-1-git-send-email-preid@electromag.com.au>
Cc: Phil Reid <preid@electromag.com.au>
To: peppe.cavallaro@st.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 203-59-230-133.perm.iinet.net.au ([203.59.230.133]:58250 "EHLO
	preid-centos7.electromag.com.au" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751473AbbJ3Ixr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 04:53:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil Reid (1):
  stmmac: Correctly report PTP capabilities.

 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

-- 
1.8.3.1
