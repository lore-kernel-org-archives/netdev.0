From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macsec: fix netlink attribute for key id
Date: Fri, 20 May 2016 11:14:47 -0700 (PDT)
Message-ID: <20160520.111447.207901690034578510.davem@davemloft.net>
References: <fdff01d3a343b5ee16cd034d743b62a543befcf4.1463570397.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbcETSOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 14:14:49 -0400
In-Reply-To: <fdff01d3a343b5ee16cd034d743b62a543befcf4.1463570397.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Wed, 18 May 2016 13:34:40 +0200

> In my last commit I replaced MACSEC_SA_ATTR_KEYID by
> MACSEC_SA_ATTR_KEY.
> 
> Fixes: 8acca6acebd0 ("macsec: key identifier is 128 bits, not 64")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable, thanks.
