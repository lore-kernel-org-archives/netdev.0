From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: Couple of fixes
Date: Tue, 14 Mar 2017 13:59:59 +0100
Message-ID: <1489496401-4820-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:35926 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750848AbdCNNAE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 09:00:04 -0400
Received: by mail-wr0-f179.google.com with SMTP id u108so123381245wrb.3
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 06:00:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple or small fixes.

Jiri Pirko (2):
  mlxsw: reg: Fix SPVM max record count
  mlxsw: reg: Fix SPVMLR max record count

 drivers/net/ethernet/mellanox/mlxsw/reg.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

-- 
2.7.4
