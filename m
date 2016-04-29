From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: constify is_skb_forwardable's arguments
Date: Fri, 29 Apr 2016 16:15:05 -0400 (EDT)
Message-ID: <20160429.161505.1249505477051341988.davem@davemloft.net>
References: <1461859168-6217-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55763 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbcD2UPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 16:15:07 -0400
In-Reply-To: <1461859168-6217-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu, 28 Apr 2016 17:59:28 +0200

> is_skb_forwardable is not supposed to change anything so constify its
> arguments
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
