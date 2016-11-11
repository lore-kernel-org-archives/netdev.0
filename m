From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 0/2] bnxt_en: 2 bug fixes.
Date: Fri, 11 Nov 2016 00:11:41 -0500
Message-ID: <1478841103-22413-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33581 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755800AbcKKFLy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 00:11:54 -0500
Received: by mail-pf0-f175.google.com with SMTP id d2so5412735pfd.0
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 21:11:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug fixes in bnxt_setup_tc() and VF vitual link state.

Michael Chan (2):
  bnxt_en: Fix ring arithmetic in bnxt_setup_tc().
  bnxt_en: Fix VF virtual link state.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c       | 11 ++++++-----
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c |  4 ++--
 2 files changed, 8 insertions(+), 7 deletions(-)

-- 
1.8.3.1
