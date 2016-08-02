From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] qed: Fix error return code in qed_resc_alloc()
Date: Mon, 01 Aug 2016 21:37:58 -0700 (PDT)
Message-ID: <20160801.213758.1421305334119915552.davem@davemloft.net>
References: <1470099334-14490-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
	everest-linux-l2@qlogic.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60570 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbcHBEi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 00:38:56 -0400
In-Reply-To: <1470099334-14490-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue,  2 Aug 2016 00:55:34 +0000

> Fix to return error code -EINVAL instead of 0 when EQ elements is
> too larger, as done elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>

Applied, thanks.
