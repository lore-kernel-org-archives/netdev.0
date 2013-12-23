From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next v2 0/5] sctp: fix checkpatch errors
Date: Mon, 23 Dec 2013 12:16:49 +0800
Message-ID: <1387772214-26068-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <vyasevich@gmail.com>,
	<nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:47511 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756689Ab3LWERW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 23:17:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix checkpatch errors.

v1 -> v2:
  -patch1: add Neil's Ack
  -patch2: fix the subject line which is not clearly pointed out by Neil
  -patch3: add Neil's Ack
  -patch4: fix the subject line and blurb which is not clearly pointed out by Neil

Wang Weidong (5):
  sctp: fix checkpatch errors with space required or prohibited
  sctp: fix checkpatch errors with (foo*)|foo * bar|foo* bar
  sctp: fix checkpatch errors with indent
  sctp: fix checkpatch errors with open brace '{' and trailing
    statements
  sctp: fix checkpatch errors with //commen

 net/sctp/auth.c          | 27 +++++++++---------
 net/sctp/chunk.c         |  4 +--
 net/sctp/input.c         | 58 +++++++++++++++++++--------------------
 net/sctp/ipv6.c          |  2 +-
 net/sctp/objcnt.c        |  2 +-
 net/sctp/output.c        | 11 ++++----
 net/sctp/outqueue.c      |  8 +++---
 net/sctp/proc.c          |  8 +++---
 net/sctp/protocol.c      |  4 +--
 net/sctp/sm_make_chunk.c | 71 ++++++++++++++++++++++++------------------------
 net/sctp/sm_sideeffect.c |  4 +--
 net/sctp/sm_statefuns.c  | 27 +++++++++---------
 net/sctp/sm_statetable.c |  2 +-
 net/sctp/socket.c        | 53 ++++++++++++++++++------------------
 net/sctp/sysctl.c        |  2 +-
 net/sctp/ulpqueue.c      | 11 ++++----
 16 files changed, 145 insertions(+), 149 deletions(-)

-- 
1.7.12
