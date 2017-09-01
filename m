From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] mlxsw: spectrum_router: Couple of fixes
Date: Fri,  1 Sep 2017 10:58:54 +0200
Message-ID: <20170901085856.2286-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:35395 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbdIAI67 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 04:58:59 -0400
Received: by mail-wr0-f171.google.com with SMTP id y15so4824407wrc.2
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 01:58:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido Schimmel (2):
  mlxsw: spectrum_router: Trap packets hitting anycast routes
  mlxsw: spectrum_router: Set abort trap in all virtual routers

 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

-- 
2.9.3
