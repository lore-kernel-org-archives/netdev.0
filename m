From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 0/3][v2] net: qcom/emac: various minor improvements
Date: Fri, 23 Jun 2017 14:33:27 -0500
Message-ID: <1498246410-29794-1-git-send-email-timur@codeaurora.org>
Cc: timur@codeaurora.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:50204 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754672AbdFWTde (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 15:33:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A collection of minor fixes and features to the Qualcomm Technologies
EMAC network driver.

Timur Tabi (3):
  net: qcom/emac: add shutdown function
  [v2] net: qcom/emac: do not reset the EMAC during initialization
  net: qcom/emac: add support for emulation systems

 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c | 23 +++++++++++++++++++++--
 drivers/net/ethernet/qualcomm/emac/emac.c       | 16 ++++++++++++++--
 2 files changed, 35 insertions(+), 4 deletions(-)

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
