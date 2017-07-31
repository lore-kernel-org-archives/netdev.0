From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/8] mlxsw: Various small fixes
Date: Mon, 31 Jul 2017 09:27:22 +0200
Message-ID: <20170731072730.3256-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34077 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751017AbdGaH1d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 03:27:33 -0400
Received: by mail-wm0-f65.google.com with SMTP id x64so10145056wmg.1
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 00:27:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patch series is to contribute several fixes for nits that I noticed while
working on mlxsw. The changes range from typo fixes to local improvements of
the code and have little in common besides being small in scope.

Petr Machata (8):
  mlxsw: spectrum_acl: Fix a typo
  mlxsw: reg.h: Fix a typo
  mlxsw: spectrum_router: Fix a typo
  mlxsw: Update specification of reg_ritr_type
  mlxsw: reg.h: Namespace IP2ME registers
  mlxsw: spectrum_router: Simplify a piece of code
  mlxsw: spectrum_router: Clarify a piece of code
  mlxsw: spectrum_router: Simplify a piece of code

 drivers/net/ethernet/mellanox/mlxsw/reg.h             | 18 +++++++++---------
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c    |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 12 +++++-------
 3 files changed, 15 insertions(+), 17 deletions(-)

-- 
2.9.3
