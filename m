From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH net-next 1/3] net:use help function of skb_checksum_start_offset
 to calculate offset
Date: Mon, 2 May 2011 18:29:11 -0400
Message-ID: <4DBF3037.30203@tilera.com>
References: <4DB1617D.30600@cn.fujitsu.com>	<4DBF2E11.3010904@tilera.com> <20110502.152136.115919893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <shanwei@cn.fujitsu.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([206.83.70.75]:38011 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758800Ab1EBW3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 18:29:17 -0400
In-Reply-To: <20110502.152136.115919893.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/2011 6:21 PM, David Miller wrote:
> From: Chris Metcalf <cmetcalf@tilera.com>
> Date: Mon, 2 May 2011 18:20:01 -0400
>
>> I took the drivers/net/tile/ change into my tree, but I'll defer to David
>> or some other net person to take the net/ipv6/udp.c change.  Thanks!
> I took them both into my tree.  Didn't you see my reply?

I did, but I didn't see the change yet in .39-rc5, so I figured it would be
harmless to also take it into the tile tree.  And, I thought you might have
just taken the platform-independent part of the change.  I'll revert the
tile part of the change out of my tree.  Thanks!

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com


