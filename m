From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] fou: avoid missing unlock in failure path
Date: Thu, 16 Apr 2015 12:11:48 -0400 (EDT)
Message-ID: <20150416.121148.1197386269946424969.davem@davemloft.net>
References: <1429123729-8282-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
	dan.carpenter@oracle.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122AbbDPQLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:11:50 -0400
In-Reply-To: <1429123729-8282-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 15 Apr 2015 11:48:49 -0700

> Fixes: 7a6c8c34e5b7 ("fou: implement FOU_CMD_GET")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
