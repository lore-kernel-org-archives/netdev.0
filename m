From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw fixes
Date: Mon, 15 Feb 2016 13:19:52 +0100
Message-ID: <1455538794-2823-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35666 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753028AbcBOMT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 07:19:57 -0500
Received: by mail-wm0-f46.google.com with SMTP id c200so110482805wme.0
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 04:19:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Just a couple of fixes from Ido.

Ido Schimmel (2):
  mlxsw: Treat local port 64 as valid
  mlxsw: spectrum: Set STP state when leaving 802.1D bridge

 drivers/net/ethernet/mellanox/mlxsw/port.h     | 2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 8 ++++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

-- 
1.9.3
