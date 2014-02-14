From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 0/4] appletalk: fix checkpatch errors or warning
Date: Fri, 14 Feb 2014 15:43:42 +0800
Message-ID: <1392363826-8256-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <acme@ghostprotocols.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:33988 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbaBNHoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 02:44:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix checkpatch errors or warning.

Wang Weidong (4):
  appletalk: fix checkpatch errors with space required or prohibited
  appletalk: fix checkpatch errors with (foo*)|foo * bar
  appletalk: convert printks to netdev_<level>
  appletalk: fix checkpatch error with indent

 net/appletalk/aarp.c |   6 +--
 net/appletalk/ddp.c  | 109 +++++++++++++++++++++++++--------------------------
 2 files changed, 57 insertions(+), 58 deletions(-)

-- 
1.7.12
