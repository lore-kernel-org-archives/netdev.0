From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/3] mlxsw: small driver update
Date: Mon, 24 Aug 2015 16:45:44 +0200
Message-ID: <1440427547-8539-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:35893 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753594AbbHXOpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 10:45:51 -0400
Received: by wicja10 with SMTP id ja10so74307902wic.1
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 07:45:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido Schimmel (1):
  mlxsw: Remove duplicate included header

Jiri Pirko (2):
  mlxsw: expose EMAD transactions statistics via debugfs
  mlxsw: adjust log messages level in __mlxsw_emad_transmit

 drivers/net/ethernet/mellanox/mlxsw/core.c | 60 ++++++++++++++++++++++++++----
 1 file changed, 52 insertions(+), 8 deletions(-)

-- 
1.9.3
