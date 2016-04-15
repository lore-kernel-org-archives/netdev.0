From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] mlxsw: spectrum_buffers: couple of cosmetic patches
Date: Fri, 15 Apr 2016 15:09:36 +0200
Message-ID: <1460725778-14655-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, David.Laight@ACULAB.COM
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:34589 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbcDONJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 09:09:41 -0400
Received: by mail-wm0-f47.google.com with SMTP id l6so9399601wml.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 06:09:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As suggested by David Laight

Jiri Pirko (2):
  mlxsw: spectrum_buffers: Use designated initializers for mlxsw_sp_pbs
  mlxsw: spectrum_buffers: Use MLXSW_SP_PB_UNUSED define for unused pb

 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

-- 
2.5.5
