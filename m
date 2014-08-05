From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4i : Move stray CPL definitions to cxgb4
 driver
Date: Tue, 05 Aug 2014 16:30:28 -0700 (PDT)
Message-ID: <20140805.163028.1815917490979635638.davem@davemloft.net>
References: <1407194271-620-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hch@infradead.org, kxie@chelsio.com,
	hariprasad@chelsio.com, leedom@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327AbaHEXa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 19:30:29 -0400
In-Reply-To: <1407194271-620-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Mon,  4 Aug 2014 16:17:51 -0700

> These belong to the t4 msg header, will ensure there is no accidental code
> duplication in the future
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

Applied, thank you.
