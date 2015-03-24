From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] net: allow to delete a whole device group
Date: Tue, 24 Mar 2015 15:41:15 -0400 (EDT)
Message-ID: <20150324.154115.1825066009543573536.davem@davemloft.net>
References: <1427223211-5781-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752787AbbCXTlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 15:41:18 -0400
In-Reply-To: <1427223211-5781-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 24 Mar 2015 11:53:31 -0700

> With dev group, we can change a batch of net devices,
> so we should allow to delete them together too.
> 
> Group 0 is not allowed to be deleted since it is
> the default group.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
