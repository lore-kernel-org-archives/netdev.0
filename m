From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch ipsec-next 0/5] xfrm: fix checkpatch errors
Date: Fri, 20 Dec 2013 18:49:32 +0800
Message-ID: <1387536577-11480-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:25126 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932271Ab3LTKt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 05:49:59 -0500
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
 net/xfrm/xfrm_state.c  | 18 +++++++++---------
 net/xfrm/xfrm_user.c   |  6 +++---
 5 files changed, 34 insertions(+), 35 deletions(-)

-- 
1.7.12
