From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] bonding: various 802.3ad fixes
Date: Mon, 19 Jan 2015 15:19:51 -0500 (EST)
Message-ID: <20150119.151951.942179510763360937.davem@davemloft.net>
References: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jtoppins@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34086 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177AbbASUTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 15:19:54 -0500
In-Reply-To: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Date: Fri, 16 Jan 2015 10:57:23 -0500

> This patch series is a forward porting of patches we (Cumulus) are shipping
> in our 3.2 series kernels. These fixes attempt to make 802.3ad bonding mode
> more predictable in certian state machine transtions in addition to enhancing
> 802.3ad bond carrier determination based on acutal number of peered ports plus
> if the bond has an active aggregrator. Specific notes are contained within each
> patch.
> 
> For this patch series there are no userspace facing changes, a diff between
> the modinfo output showed no difference. However, there are behavioral
> facing changes, primarily in the bond carrier state. Please make sure to
> review carefully.

There was some minor feedback given to you for this series, please address
it and repost the set.

Thanks.
