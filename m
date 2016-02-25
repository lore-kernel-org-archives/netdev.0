From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2 0/2] net_sched: add network namespace
 support for tc actions
Date: Thu, 25 Feb 2016 14:16:55 -0500 (EST)
Message-ID: <20160225.141655.1671211413530526608.davem@davemloft.net>
References: <1456185473-25403-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44645 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933357AbcBYTQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 14:16:58 -0500
In-Reply-To: <1456185473-25403-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 22 Feb 2016 15:57:51 -0800

> This patchset adds network namespace support for tc actions.
> 
> v2:
> * pull the first patch into net-next
> * reduce code duplication by introducing more helper functions

Series applied, thanks.
