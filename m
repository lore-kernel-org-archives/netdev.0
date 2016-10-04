From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: Couple of fixes
Date: Tue,  4 Oct 2016 09:46:03 +0200
Message-ID: <1475567165-3362-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35356 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752253AbcJDHqI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 03:46:08 -0400
Received: by mail-wm0-f48.google.com with SMTP id f193so150733421wmg.0
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2016 00:46:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of fixes from Yotam.

Yotam Gigi (2):
  mlxsw: spectrum: Fix misuse of hard_header_len
  mlxsw: switchx2: Fix misuse of hard_header_len

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 2 +-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

-- 
2.5.5
