From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/3] mlxsw: small driver update
Date: Thu, 27 Aug 2015 17:59:54 +0200
Message-ID: <1440691197-25780-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38562 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbbH0QAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 12:00:01 -0400
Received: by wicgk12 with SMTP id gk12so13848111wic.1
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 09:00:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido Schimmel (2):
  mlxsw: Remove duplicate included header
  mlxsw: Make mailboxes 4KB aligned

Jiri Pirko (1):
  mlxsw: adjust transmit fail log message level in __mlxsw_emad_transmit

 drivers/net/ethernet/mellanox/mlxsw/core.c |  5 +-
 drivers/net/ethernet/mellanox/mlxsw/pci.c  | 83 ++++++++++++++++++------------
 2 files changed, 52 insertions(+), 36 deletions(-)

-- 
1.9.3
