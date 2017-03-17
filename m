From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] mlxsw: small driver update
Date: Fri, 17 Mar 2017 09:37:59 +0100
Message-ID: <1489739881-2826-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33241 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751039AbdCQIqB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 04:46:01 -0400
Received: by mail-wr0-f196.google.com with SMTP id g10so8684323wrg.0
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 01:46:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Contains two cleanup patches.

Arkadi Sharshevsky (1):
  mlxsw: spectrum: Cosmetic naming change

Or Gerlitz (1):
  mlxsw: spectrum: Align the matchall default case returned value

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  10 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   4 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 282 +++++++++++----------
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   4 +-
 4 files changed, 153 insertions(+), 147 deletions(-)

-- 
2.7.4
