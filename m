From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: em_canid: remove useless statements from
 em_canid_change
Date: Sat, 21 Jun 2014 15:40:36 -0700 (PDT)
Message-ID: <20140621.154036.2087202508923213287.davem@davemloft.net>
References: <53A15267.7050304@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lisovy@gmail.com, netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbaFUWkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2014 18:40:37 -0400
In-Reply-To: <53A15267.7050304@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Wed, 18 Jun 2014 16:48:39 +0800

> tcf_ematch is allocated by kzalloc in function tcf_em_tree_validate(),
> so cm_old is always NULL.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied, thanks.
