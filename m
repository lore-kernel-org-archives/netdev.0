From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2 0/2] net_sched: refactor tc action
 structures
Date: Mon, 25 Jul 2016 21:49:35 -0700 (PDT)
Message-ID: <20160725.214935.1694554725836014999.davem@davemloft.net>
References: <1469488182-12296-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbcGZEti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 00:49:38 -0400
In-Reply-To: <1469488182-12296-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 25 Jul 2016 16:09:40 -0700

> These two patches factor out the struct tcf_common.
> 
> v2: fix a compile warning

Series applied.
