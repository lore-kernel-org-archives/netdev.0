From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next 0/5] xfrm: fix checkpatch errors
Date: Thu, 19 Dec 2013 20:22:09 +0800
Message-ID: <1387455734-7624-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:7789 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932195Ab3LSMW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 07:22:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

fix checkpatch errors.

Weilong Chen (5):
  xfrm: checkpatch errors with space
  xfrm: checkpatch errors with foo * bar
  xfrm: checkpatch erros with space prohibited
  xfrm: fix checkpatch error
  xfrm: checkpatch erros with inline keyword position

 net/xfrm/xfrm_input.c  |  6 +++---
 net/xfrm/xfrm_policy.c | 37 ++++++++++++++++++-------------------
 net/xfrm/xfrm_proc.c   |  2 +-
 net/xfrm/xfrm_state.c  | 20 ++++++++++----------
 net/xfrm/xfrm_user.c   |  6 +++---
 5 files changed, 35 insertions(+), 36 deletions(-)

-- 
1.7.12
