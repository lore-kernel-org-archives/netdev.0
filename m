From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [GIT PULL] Please pull two IEEE 802.15.4 patches.
Date: Thu, 18 Jun 2009 18:16:45 +0400
Message-ID: <1245334607-16046-1-git-send-email-dbaryshkov@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slapin@ossfans.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f212.google.com ([209.85.220.212]:38822 "EHLO
	mail-fx0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049AbZFRORD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 10:17:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The following changes since commit 81e2a3d5b75cbf0b42428b9d5a7cc7c85be9e7a7:
  Eric Dumazet (1):
        atm: sk_wmem_alloc initial value is one

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git for-linus

Dmitry Eremin-Solenikov (2):
      ieee802154: use standard routine for printing dumps
      MAINTAINERS: fix IEEE 802.15.4 entry

 MAINTAINERS                    |    4 ++--
 net/ieee802154/af_ieee802154.c |   12 +++---------
 2 files changed, 5 insertions(+), 11 deletions(-)
