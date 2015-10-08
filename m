From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: couple of fixes
Date: Thu,  8 Oct 2015 15:17:36 +0200
Message-ID: <1444310258-6563-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:38883 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757530AbbJHNRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 09:17:41 -0400
Received: by wiclk2 with SMTP id lk2so24879348wic.1
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 06:17:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Just a couple of small fixes.

Elad Raz (1):
  mlxsw: switchx2: changing order of exit fallbacks

Ido Schimmel (1):
  mlxsw: Fix bug in __mlxsw_item_bit_array_offset

 drivers/net/ethernet/mellanox/mlxsw/item.h     | 4 +++-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

-- 
1.9.3
