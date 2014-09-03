From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 2/2] ipv6: use addrconf_get_prefix_route() to remove peer
 addr
Date: Thu, 04 Sep 2014 01:51:30 +0200
Message-ID: <1409788290.3100711.163378825.3D3B82CE@webmail.messagingengine.com>
References: <1409781562-4191-1-git-send-email-nicolas.dichtel@6wind.com>
 <1409781562-4191-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:57262 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933258AbaICXva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 19:51:30 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id 49F3D2097F
	for <netdev@vger.kernel.org>; Wed,  3 Sep 2014 19:51:30 -0400 (EDT)
In-Reply-To: <1409781562-4191-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 3, 2014, at 23:59, Nicolas Dichtel wrote:
> addrconf_get_prefix_route() ensures to get the right route in the right
> table.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Also good!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
