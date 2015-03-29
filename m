From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net 1/2] fib6: install fib6 ops in the last step
Date: Sun, 29 Mar 2015 12:14:16 -0700 (PDT)
Message-ID: <20150329.121416.377212794966016192.davem@davemloft.net>
References: <1427319903-22976-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59026 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376AbbC2TFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 15:05:32 -0400
In-Reply-To: <1427319903-22976-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 25 Mar 2015 14:45:02 -0700

> We should not commit the new ops until we finish
> all the setup, otherwise we have to NULL it on failure.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied to net-next
