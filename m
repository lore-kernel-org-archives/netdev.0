From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 0/9] net: support multiple independant multicast routing instances
Date: Tue, 13 Apr 2010 17:03:14 +0200
Message-ID: <1271171003-11901-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51248 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449Ab0DMPD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 11:03:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

this is an updated patchset of my patches to support multiple independant
multicast routing instances. Changes since the last posting are:

- rebase to the current net-next-2.6.git tree
- fix up patch subjects to consistently refer to "ipv4: ipmr:"
- fix up list_head conversion patch to add new elements at the head of
  the list instead of at the tail

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/ipmr-2.6.git master

Thanks!

