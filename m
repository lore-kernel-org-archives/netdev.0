From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/hyperv: rx_bytes should account the ether header
 size
Date: Wed, 01 Feb 2012 14:30:10 -0500 (EST)
Message-ID: <20120201.143010.1818830777509458347.davem@davemloft.net>
References: <CAPgLHd8M7vPra_gTH5J1RmR4nmSeuDEGCjghatd1BsOJEeGKKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, kys@microsoft.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450Ab2BATaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 14:30:16 -0500
In-Reply-To: <CAPgLHd8M7vPra_gTH5J1RmR4nmSeuDEGCjghatd1BsOJEeGKKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 30 Jan 2012 16:14:02 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> skb->len after call eth_type_trans() does not include the ether
> header size, but rx_bytes should account it.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
