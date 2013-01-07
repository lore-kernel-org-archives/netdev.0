From: Antonio Quartulli <ordex@autistici.org>
Subject: pull request: batman-adv 2013-01-07
Date: Mon,  7 Jan 2013 12:11:26 +0100
Message-ID: <1357557088-17866-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:58663 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626Ab3AGLM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 06:12:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

here are two harmless "fixes" intended for net:
one is fixing the versioning number in order to keep it in sync with the year of
release and the other simply updates the copyright years in each and every file.

Please pull or let me know if you find any problem.

Thanks a lot,
	Antonio


The following changes since commit c7e2e1d72ed7707239d20525e0ebcad7e3303659:

  ipv4: fix NULL checking in devinet_ioctl() (2013-01-06 21:11:18 -0800)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to d5c184eec815d28d042683f578f6d93224d9dfa9:

  batman-adv: update copyright years (2013-01-07 11:43:19 +0100)

----------------------------------------------------------------
Included fixes are:
- Fix version number to keep consistency with the year of release
- Update copyright years to 2013 in each file

----------------------------------------------------------------
Antonio Quartulli (2):
      batman-adv: Start new development cycle
      batman-adv: update copyright years

 net/batman-adv/bat_algo.h              | 2 +-
 net/batman-adv/bat_iv_ogm.c            | 2 +-
 net/batman-adv/bitarray.c              | 2 +-
 net/batman-adv/bitarray.h              | 2 +-
 net/batman-adv/bridge_loop_avoidance.c | 2 +-
 net/batman-adv/bridge_loop_avoidance.h | 2 +-
 net/batman-adv/debugfs.c               | 2 +-
 net/batman-adv/debugfs.h               | 2 +-
 net/batman-adv/distributed-arp-table.c | 2 +-
 net/batman-adv/distributed-arp-table.h | 2 +-
 net/batman-adv/gateway_client.c        | 2 +-
 net/batman-adv/gateway_client.h        | 2 +-
 net/batman-adv/gateway_common.c        | 2 +-
 net/batman-adv/gateway_common.h        | 2 +-
 net/batman-adv/hard-interface.c        | 2 +-
 net/batman-adv/hard-interface.h        | 2 +-
 net/batman-adv/hash.c                  | 2 +-
 net/batman-adv/hash.h                  | 2 +-
 net/batman-adv/icmp_socket.c           | 2 +-
 net/batman-adv/icmp_socket.h           | 2 +-
 net/batman-adv/main.c                  | 2 +-
 net/batman-adv/main.h                  | 4 ++--
 net/batman-adv/originator.c            | 2 +-
 net/batman-adv/originator.h            | 2 +-
 net/batman-adv/packet.h                | 2 +-
 net/batman-adv/ring_buffer.c           | 2 +-
 net/batman-adv/ring_buffer.h           | 2 +-
 net/batman-adv/routing.c               | 2 +-
 net/batman-adv/routing.h               | 2 +-
 net/batman-adv/send.c                  | 2 +-
 net/batman-adv/send.h                  | 2 +-
 net/batman-adv/soft-interface.c        | 2 +-
 net/batman-adv/soft-interface.h        | 2 +-
 net/batman-adv/sysfs.c                 | 2 +-
 net/batman-adv/sysfs.h                 | 2 +-
 net/batman-adv/translation-table.c     | 2 +-
 net/batman-adv/translation-table.h     | 2 +-
 net/batman-adv/types.h                 | 2 +-
 net/batman-adv/unicast.c               | 2 +-
 net/batman-adv/unicast.h               | 2 +-
 net/batman-adv/vis.c                   | 2 +-
 net/batman-adv/vis.h                   | 2 +-
 42 files changed, 43 insertions(+), 43 deletions(-)
