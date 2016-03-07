From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: couple of fixes
Date: Mon,  7 Mar 2016 09:24:50 +0100
Message-ID: <1457339092-2878-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35823 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbcCGIY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 03:24:56 -0500
Received: by mail-wm0-f42.google.com with SMTP id l68so74083486wml.0
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 00:24:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of fixes from Ido.

Ido Schimmel (2):
  mlxsw: spectrum: Always decrement bridge's ref count
  mlxsw: pci: Correctly determine if descriptor queue is full

 drivers/net/ethernet/mellanox/mlxsw/pci.c      | 2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 4 +---
 2 files changed, 2 insertions(+), 4 deletions(-)

-- 
2.5.0
