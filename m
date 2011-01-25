From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next-2.6] IPVS changes for 2.6.38-rc3
Date: Tue, 25 Jan 2011 23:17:04 +1000
Message-ID: <1295961426-7402-1-git-send-email-horms@verge.net.au>
Cc: Changli Gao <xiaosuo@gmail.com>, Julian Anastasov <ja@ssi.bg>,
	Patrick McHardy <kaber@trash.net>
To: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:33204 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753082Ab1AYNRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 08:17:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick,

please consider pulling
  git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git for-patrick

Which includes the following changes, both of which I believe 2.6.38 material.

Changli Gao (1):
      netfilter: ipvs: fix compiler warnings

Hans Schillstrom (1):
      IPVS netns BUG, register sysctl for root ns

 net/netfilter/ipvs/ip_vs_core.c |    4 +---
 net/netfilter/ipvs/ip_vs_ctl.c  |    2 +-
 2 files changed, 2 insertions(+), 4 deletions(-)

