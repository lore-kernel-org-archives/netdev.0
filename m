From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunvnet: don't change gso data on clones
Date: Wed, 11 Feb 2015 19:41:55 -0800 (PST)
Message-ID: <20150211.194155.1823377665028874866.davem@davemloft.net>
References: <54DB5711.3040705@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754204AbbBLDex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 22:34:53 -0500
In-Reply-To: <54DB5711.3040705@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Wed, 11 Feb 2015 08:20:17 -0500

> This patch unclones an skb for the case where the sunvnet driver needs to
> change the segmentation size so that it doesn't interfere with TCP SACK's
> use of them.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>

Applied, thanks.
