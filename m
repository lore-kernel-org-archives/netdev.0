From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request: batman-adv 2014-01-16
Date: Thu, 16 Jan 2014 00:24:22 +0100
Message-ID: <1389828263-798-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:35709 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482AbaAOXZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 18:25:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here you have one more change by Simon Wunderlich intended for
net-next/linux-3.14.

This patch is properly formatting some kerneldoc that we already had but
which has not been written down in a proper way.


Please pull or let me know if something is wrong!

Thanks a lot,
	Antonio



The following changes since commit b93819854d6e79999a01ae73f90d3a4b06816cf7:

  stmmac: Add vlan rx for better GRO performance. (2014-01-15 15:13:08 -0800)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 1b371d13071d6b6b9dc7a00fe1bc5a6babd68a5b:

  batman-adv: use consistent kerneldoc style (2014-01-16 00:16:00 +0100)

----------------------------------------------------------------
Included change:
- properly format already existing kerneldoc

----------------------------------------------------------------
Simon Wunderlich (1):
      batman-adv: use consistent kerneldoc style

 net/batman-adv/bat_iv_ogm.c            |  6 ++++--
 net/batman-adv/bridge_loop_avoidance.c | 24 ++++++++++++++++++------
 net/batman-adv/translation-table.c     |  8 +++++---
 net/batman-adv/types.h                 |  6 ++++--
 4 files changed, 31 insertions(+), 13 deletions(-)
