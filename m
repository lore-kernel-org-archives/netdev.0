From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request: batman-adv 20140518
Date: Sun, 18 May 2014 19:58:07 +0200
Message-ID: <1400435890-6667-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:4047 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbaERR7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 13:59:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here you have our pull request for net-next.

Unfortunately this time we have nothing exciting for you (as you may have seen
we preferred to focus on bug fixing during the last period).

Patch 1 and 2 slightly improve our codestyle in order to respect two new
checks that have been recently introduced in checkpatch.

Patch 3 is just increasing our internal version number.


Please pull or let me know of any problem.

Thanks a lot!
	Antonio


The following changes since commit 33fcc5e05ea2b43ce0c6d356424ee5e25406f4c2:

  Merge branch 'cdc_ncm-coalesce' (2014-05-16 22:39:13 -0400)

are available in the git repository at:


  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 871d3d9fdf1c2fb58927080c8e96edccb1fee010:

  batman-adv: Start new development cycle (2014-05-18 15:04:00 +0200)

----------------------------------------------------------------
Included changes:
- fix codestyle to respect new checkpatch warnings
- increase internal version number

----------------------------------------------------------------
Antonio Quartulli (2):
      batman-adv: add blank line between declarations and the rest of the code
      batman-adv: remove semi-colon after macro definition

Simon Wunderlich (1):
      batman-adv: Start new development cycle

 net/batman-adv/debugfs.c               | 13 +++++++++++--
 net/batman-adv/distributed-arp-table.c |  1 +
 net/batman-adv/main.h                  |  2 +-
 net/batman-adv/network-coding.c        |  1 +
 net/batman-adv/sysfs.c                 | 14 ++++++++++++--
 5 files changed, 26 insertions(+), 5 deletions(-)
