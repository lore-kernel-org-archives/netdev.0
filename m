From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/3] Trivial ixgbe cleanups
Date: Sun, 22 Aug 2010 19:52:59 -0700
Message-ID: <cover.1282531322.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1222 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751749Ab0HWCxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 22:53:07 -0400
Received: from Joe-Laptop.home (unknown [192.168.1.151])
	by mail.perches.com (Postfix) with ESMTP id 2836B24368
	for <netdev@vger.kernel.org>; Sun, 22 Aug 2010 19:52:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Basically just checkpatch cleanups

Joe Perches (3):
  drivers/net/ixgbe/ixgbe_main.c: Checkpatch cleanups, mostly whitespace
  drivers/net/ixgbe/ixgbe_main.c: Use pr_<level>
  drivers/net/ixgbe/ixgbe_main.c: Add ixgbe_psum

 drivers/net/ixgbe/ixgbe_main.c |  810 ++++++++++++++++++++--------------------
 1 files changed, 409 insertions(+), 401 deletions(-)

-- 
1.7.2.19.g9a302

