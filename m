From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/2] macvlan: slight optimization for fast path
Date: Tue, 27 May 2014 18:53:14 +0800
Message-ID: <1401187996-10252-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:5246 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbaE0Kxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 06:53:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong (2):
  macvlan: slight optimization for passthru mode
  macvlan: slight optimization for macvlan_handle_frame

 drivers/net/macvlan.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

-- 
1.8.0
