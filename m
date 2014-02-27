From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] neigh: directly goto out after setting
 nud_state to NUD_FAILED
Date: Thu, 27 Feb 2014 16:41:01 -0500 (EST)
Message-ID: <20140227.164101.979079138694412921.davem@davemloft.net>
References: <530EFF47.6090001@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49689 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbaB0VlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 16:41:07 -0500
In-Reply-To: <530EFF47.6090001@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Thu, 27 Feb 2014 17:03:03 +0800

> Because those following if conditions will not be matched.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied, thank you.
