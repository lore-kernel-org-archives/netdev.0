From: Antonio Quartulli <ordex@autistici.org>
Subject: pull request: batman-adv 2013-01-29
Date: Tue, 29 Jan 2013 08:07:59 +0100
Message-ID: <1359443280-28835-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:61828 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270Ab3A2HJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 02:09:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here you have just a single patch which is fixing a pesky bug that I introduced
within a patchset recently sent to net-next/linux-3.9.
It is not big, but I think it is worth fixing the new behaviour before it
gets released.

Please pull or let me know if there is any problem.
Thanks a lot,
	Antonio



The following changes since commit cef401de7be8c4e155c6746bfccf721a4fa5fab9:

  net: fix possible wrong checksum generation (2013-01-28 00:27:15 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to a7966d908ae8472e8183496916b7baec5f65b3a6:

  batman-adv: fix local translation table output (2013-01-28 20:46:03 +0100)

----------------------------------------------------------------
Included changes:
- fix recently introduced output behaviour

----------------------------------------------------------------
Antonio Quartulli (1):
      batman-adv: fix local translation table output

 net/batman-adv/translation-table.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
