From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 0/2] tipc: do some fixups
Date: Tue, 17 Dec 2013 15:03:45 +0800
Message-ID: <1387263827-20876-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <David.Laight@ACULAB.COM>, <netdev@vger.kernel.org>
To: <jon.maloy@ericsson.com>, <allan.stephens@windriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:2850 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600Ab3LQHEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 02:04:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in commit 0cee6bbe06f and 3b8401fe9dba not make the
code best. so fix them, as suggested by David Laight.

Wang Weidong (2):
  tipc: make the code look more better
  tipc: make the code look more readability

 net/tipc/port.c   | 13 ++++++-------
 net/tipc/socket.c |  7 ++-----
 2 files changed, 8 insertions(+), 12 deletions(-)

-- 
1.7.12
