From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: Couple of fixes
Date: Tue, 25 Oct 2016 11:25:55 +0200
Message-ID: <1477387557-5048-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37740 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756998AbcJYJ0A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 05:26:00 -0400
Received: by mail-wm0-f45.google.com with SMTP id c78so12587069wme.0
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 02:25:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of LPM tree management fixes.

Jiri Pirko (2):
  mlxsw: spectrum_router: Save requested prefix bitlist when creating
    tree
  mlxsw: spectrum_router: Compare only trees which are in use during
    tree get

 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

-- 
2.5.5
