From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vlan: fix comment for vlan_ethhdr->h_vlan_proto
Date: Wed, 19 Jun 2013 23:17:18 -0700 (PDT)
Message-ID: <20130619.231718.566676542331651980.davem@davemloft.net>
References: <1371222421-6397-1-git-send-email-olaf@aepfle.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: olaf@aepfle.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790Ab3FTGRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 02:17:19 -0400
In-Reply-To: <1371222421-6397-1-git-send-email-olaf@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Olaf Hering <olaf@aepfle.de>
Date: Fri, 14 Jun 2013 17:07:01 +0200

> After addition of 8021AD h_vlan_proto can be either ETH_P_8021Q or
> ETH_P_8021AD.
> 
> Signed-off-by: Olaf Hering <olaf@aepfle.de>

Applied, thanks.
