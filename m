From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 0/6] net_sched: clean up some chekpatch errors
Date: Tue, 10 Dec 2013 20:55:28 +0800
Message-ID: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:22047 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908Ab3LJMzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 07:55:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up some checkpatch errors in "net/sched/*"

Yang Yingliang (6):
  net_sched: remove unnecessary parentheses while return
  net_sched: cls_bpf: use tabs to do indent
  net_sched: change "foo* bar" to "foo *bar"
  net_sched: add space around '>' and before '('
  net_sched: sfq: put sfq_unlink in a do - while loop
  net_sched: make macro be enclosed in parenthesis

 net/sched/act_api.c     |  3 ++-
 net/sched/cls_bpf.c     |  2 +-
 net/sched/cls_u32.c     |  2 +-
 net/sched/em_meta.c     |  4 +++-
 net/sched/sch_cbq.c     |  3 ++-
 net/sched/sch_dsmark.c  |  2 +-
 net/sched/sch_generic.c |  4 ++--
 net/sched/sch_netem.c   |  2 +-
 net/sched/sch_sfq.c     | 10 ++++++----
 9 files changed, 19 insertions(+), 13 deletions(-)

-- 
1.8.0
