From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next v3 0/7] fix checkpatch errors
Date: Mon, 23 Dec 2013 13:57:19 +0800
Message-ID: <1387778246-15300-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<netfilter@vger.kernel.org>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:61906 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362Ab3LWF6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 00:58:30 -0500
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
  ipv4: ipv4: Cleanup the comments in tcp_yeah.c

 net/ipv4/cipso_ipv4.c                  |  9 ++---
 net/ipv4/igmp.c                        | 70 +++++++++++++++++-----------------
 net/ipv4/inetpeer.c                    |  4 +-
 net/ipv4/ip_options.c                  | 12 +++---
 net/ipv4/netfilter/nf_nat_snmp_basic.c | 12 +++---
 net/ipv4/syncookies.c                  |  2 +-
 net/ipv4/sysctl_net_ipv4.c             |  2 +-
 net/ipv4/tcp_input.c                   |  4 +-
 net/ipv4/tcp_ipv4.c                    |  2 +-
 net/ipv4/tcp_probe.c                   |  4 +-
 net/ipv4/tcp_yeah.c                    | 20 +++++-----
 net/ipv4/xfrm4_mode_beet.c             |  2 +-
 12 files changed, 70 insertions(+), 73 deletions(-)

-- 
1.7.12
