From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] mlxsw: Fixlets
Date: Mon,  2 Oct 2017 12:21:56 +0200
Message-ID: <20171002102158.2443-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:49428 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750949AbdJBKWA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 06:22:00 -0400
Received: by mail-wm0-f66.google.com with SMTP id b189so5736072wmd.4
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 03:21:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of small nit fixes from Petr

Petr Machata (2):
  mlxsw: spectrum_router: Fix a typo
  mlxsw: spectrum_router: Drop a redundant condition

 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

-- 
2.9.5
