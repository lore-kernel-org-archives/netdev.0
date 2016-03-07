From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 0/2] mlxsw: couple of fixes
Date: Mon,  7 Mar 2016 15:15:28 +0100
Message-ID: <1457360130-23871-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34232 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273AbcCGOPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 09:15:34 -0500
Received: by mail-wm0-f43.google.com with SMTP id p65so110057077wmp.1
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 06:15:33 -0800 (PST)
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
