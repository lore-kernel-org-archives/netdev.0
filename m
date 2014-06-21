From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] bridge: use
 list_for_each_entry_continue_reverse
Date: Sat, 21 Jun 2014 15:33:41 -0700 (PDT)
Message-ID: <20140621.153341.1779507155270513523.davem@davemloft.net>
References: <1403078836-14660-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbaFUWdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2014 18:33:42 -0400
In-Reply-To: <1403078836-14660-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Wed, 18 Jun 2014 16:07:16 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> use list_for_each_entry_continue_reverse to rollback in fdb_add_hw
> when add address failed
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied to net-next, thanks.
