From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: fix code identation
Date: Mon, 22 Sep 2014 14:52:33 -0400 (EDT)
Message-ID: <20140922.145233.858465532218349114.davem@davemloft.net>
References: <1411107963-8303-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbaIVSwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 14:52:36 -0400
In-Reply-To: <1411107963-8303-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Fri, 19 Sep 2014 14:26:03 +0800

> There have extra identation before .skb_copy_to_linear_data_offset(),
> this patch just remove the identation.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied, thanks.
