From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next 0/5] mac80211: clean up some chekpatch errors
Date: Wed, 18 Dec 2013 15:44:11 +0800
Message-ID: <1387352656-860-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <linville@tuxdriver.com>,
	<johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:15408 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014Ab3LRHpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:45:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Clean up some checkpatch errors in mac80211.

Weilong Chen (5):
  mac80211: fix checkpatch error
  mac80211: fix checkpatch error
  mac80211: fix checkpatch error
  mac80211: fix checkpatch error
  mac80211: fix checkpatch error

 net/mac80211/aes_cmac.c            | 2 +-
 net/mac80211/aes_cmac.h            | 2 +-
 net/mac80211/rc80211_minstrel.c    | 8 ++++----
 net/mac80211/rc80211_minstrel_ht.c | 2 +-
 net/mac80211/sta_info.h            | 2 +-
 net/mac80211/tkip.c                | 2 +-
 net/mac80211/trace.h               | 2 +-
 net/mac80211/tx.c                  | 4 ++--
 net/mac80211/util.c                | 2 +-
 9 files changed, 13 insertions(+), 13 deletions(-)

-- 
1.7.12
