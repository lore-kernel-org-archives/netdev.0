From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: Use ERR_CAST inlined function instead
 of ERR_PTR(PTR_ERR(...))
Date: Mon, 04 Nov 2013 20:03:03 -0500 (EST)
Message-ID: <20131104.200303.1549746023350899879.davem@davemloft.net>
References: <52733797.3010305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629Ab3KEBDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 20:03:04 -0500
In-Reply-To: <52733797.3010305@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Fri, 01 Nov 2013 13:09:43 +0800

> trivial patch converting ERR_PTR(PTR_ERR()) into ERR_CAST().
> No functional changes.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied, thank you.
