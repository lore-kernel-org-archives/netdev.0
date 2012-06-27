From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] be2net: Fix to trim skb for padded vlan
 packets to workaround an ASIC Bug
Date: Wed, 27 Jun 2012 01:36:07 -0700 (PDT)
Message-ID: <20120627.013607.1203331705442562498.davem@davemloft.net>
References: <879c023f-1730-4874-a943-58b6725f80f4@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753514Ab2F0IgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:36:07 -0400
In-Reply-To: <879c023f-1730-4874-a943-58b6725f80f4@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Wed, 27 Jun 2012 14:02:10 +0530

> Fixed spelling error in a comment as pointed out by DaveM.
> Also refactored existing code a bit to provide placeholders for another ASIC
> Bug workaround that will be checked-in soon after this.
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Applied, thanks.
