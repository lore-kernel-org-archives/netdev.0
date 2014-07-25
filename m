From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Fixed incorrect check for memory
 operation in t4_memory_rw
Date: Thu, 24 Jul 2014 23:28:58 -0700 (PDT)
Message-ID: <20140724.232858.492013660017227101.davem@davemloft.net>
References: <1406202390-23012-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759853AbaGYG27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 02:28:59 -0400
In-Reply-To: <1406202390-23012-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu, 24 Jul 2014 17:16:30 +0530

> Fix incorrect check introduced in commit fc5ab020 ("cxgb4: Replaced the
> backdoor mechanism to access the HW memory with PCIe Window method"). We where
> checking for write operation and doing a read, changed it accordingly.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
