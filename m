From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 0/2] net_sched: do some cleanup
Date: Wed, 18 Dec 2013 20:04:50 +0800
Message-ID: <1387368292-18120-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:32247 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752666Ab3LRMFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 07:05:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prefer pr_warn(... to pr_warning(...
Do not use C99 // comments and fix spelling.

Yang Yingliang (2):
  net_sched: replace pr_warning with pr_warn
  sch_htb: use /* comments

 net/sched/sch_cbq.c    |  4 ++--
 net/sched/sch_dsmark.c |  4 ++--
 net/sched/sch_gred.c   |  4 ++--
 net/sched/sch_htb.c    | 19 +++++++++----------
 4 files changed, 15 insertions(+), 16 deletions(-)

-- 
1.8.0
