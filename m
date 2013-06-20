From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 0/2] netdev: octeon_mgmt minor fixes.
Date: Wed, 19 Jun 2013 17:40:18 -0700
Message-ID: <1371688820-4585-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-mips@linux-mips.org, David Daney <david.daney@cavium.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:58172 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935269Ab3FTAkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 20:40:31 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx10so5683429pab.41
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 17:40:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <david.daney@cavium.com>

I have two small change here for 3.11 (I hope).

David Daney (2):
  netdev: octeon_mgmt: Correct tx IFG workaround.
  netdev: octeon_mgmt: Fix structure layout for little-endian.

 drivers/net/ethernet/octeon/octeon_mgmt.c | 31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

-- 
1.7.11.7
