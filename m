From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] mlxsw: cosmetics
Date: Mon,  6 Mar 2017 21:25:19 +0100
Message-ID: <1488831921-5152-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33827 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932427AbdCFUd7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 15:33:59 -0500
Received: by mail-wm0-f65.google.com with SMTP id u132so7626270wmg.1
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 12:33:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of cosmetic mlxsw patches

Ido Schimmel (1):
  mlxsw: pci: Remove unused bit

Jiri Pirko (1):
  mlxsw: spectrum: Fix helper function and port variable names

 drivers/net/ethernet/mellanox/mlxsw/cmd.h      | 12 ------------
 drivers/net/ethernet/mellanox/mlxsw/pci.c      |  2 --
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 23 ++++++++++++-----------
 3 files changed, 12 insertions(+), 25 deletions(-)

-- 
2.7.4
