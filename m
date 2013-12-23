From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH resend net-next 0/2] net_sched: do some cleanup
Date: Mon, 23 Dec 2013 09:06:16 +0800
Message-ID: <1387760778-25256-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:54642 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756362Ab3LWBG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 20:06:26 -0500
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
1.7.12
