From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: ena: Fix error return code in
 ena_device_init()
Date: Mon, 15 Aug 2016 16:34:58 -0700 (PDT)
Message-ID: <20160815.163458.1015023557360161196.davem@davemloft.net>
References: <1471301464-24748-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netanel@annapurnalabs.com, saeed@annapurnalabs.com,
	zorik@annapurnalabs.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932271AbcHOXe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 19:34:59 -0400
In-Reply-To: <1471301464-24748-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 15 Aug 2016 22:51:04 +0000

> Fix to return a negative error code from the invalid dma width
> error handling case instead of 0.
> 
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>

Applied.
