From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v5 00/10] Adding permanent config get/set to devlink
Date: Mon, 30 Oct 2017 10:46:06 -0400
Message-ID: <1509374776-45869-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com, yuvalm@mellanox.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:51657 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751732AbdJ3Oq3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 10:46:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since v4:

* Created / used enum for permanent config param / types.
* Use bool and NLA_FLAG for restart_required indication.
* Move and reworded comments and git commit messagess for
  clarity and removed double-spaces after sentences.
