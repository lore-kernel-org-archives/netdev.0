From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next 0/7] fix checkpatch errors
Date: Fri, 20 Dec 2013 19:57:03 +0800
Message-ID: <1387540630-11052-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<netfilter@vger.kernel.org>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:45393 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755957Ab3LTL64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 06:58:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>


Weilong Chen (7):
  ipv4: do clean up with spaces
  ipv4: fix checkpatch error "space prohibited XXX"
  ipv4: fix checkpatch error with foo * bar
  ipv4: fix all space errors in file igmp.c
  ipv4: ERROR: do not initialise globals to 0 or NULL
  ipv4: ERROR: code indent should use tabs where possible
  ipv4: ERROR: do not use C99 // comments

 net/ipv4/cipso_ipv4.c                  |  6 +--
 net/ipv4/igmp.c                        | 70 +++++++++++++++++-----------------
 net/ipv4/inetpeer.c                    |  4 +-
 net/ipv4/ip_options.c                  | 12 +++---
 net/ipv4/netfilter/nf_nat_snmp_basic.c | 12 +++---
 net/ipv4/syncookies.c                  |  2 +-
 net/ipv4/sysctl_net_ipv4.c             |  2 +-
 net/ipv4/tcp_input.c                   |  4 +-
 net/ipv4/tcp_ipv4.c                    |  2 +-
 net/ipv4/tcp_probe.c                   |  4 +-
 net/ipv4/tcp_yeah.c                    | 18 ++++-----
 net/ipv4/xfrm4_mode_beet.c             |  2 +-
 12 files changed, 69 insertions(+), 69 deletions(-)

-- 
1.7.12
