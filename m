From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [GIT PULL] Fixes for the IEEE 802.15.4 code
Date: Mon, 29 Jun 2009 19:02:12 +0400
Message-ID: <1246287735-2692-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	slapin@ossfans.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:36258 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487AbZF2PCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 11:02:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull three following patches, containing small fixes for the IEEE 802.15.4
code. The branch is based against net-next/master. Thank you.

The following changes since commit 28d0325ce6e0a52f53d8af687e6427fee59004d3:
  Linus Torvalds (1):
        Linux 2.6.31-rc1

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git for-linus

Dmitry Eremin-Solenikov (3):
      MAINTAINERS: ieee802154 lists are moderated for non-subscribers.
      nl802154: fix Oops in ieee802154_nl_get_dev
      nl802154: add module license and description

 MAINTAINERS              |    2 +-
 net/ieee802154/netlink.c |    6 ++++++
 2 files changed, 7 insertions(+), 1 deletions(-)

