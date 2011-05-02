From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net:use help function of
 skb_checksum_start_offset to calculate offset
Date: Mon, 02 May 2011 15:35:54 -0700 (PDT)
Message-ID: <20110502.153554.260099779.davem@davemloft.net>
References: <4DBF2E11.3010904@tilera.com>
	<20110502.152136.115919893.davem@davemloft.net>
	<4DBF3037.30203@tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, netdev@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50736
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751646Ab1EBWg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 18:36:27 -0400
In-Reply-To: <4DBF3037.30203@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Mon, 2 May 2011 18:29:11 -0400

> On 5/2/2011 6:21 PM, David Miller wrote:
>> From: Chris Metcalf <cmetcalf@tilera.com>
>> Date: Mon, 2 May 2011 18:20:01 -0400
>>
>>> I took the drivers/net/tile/ change into my tree, but I'll defer to David
>>> or some other net person to take the net/ipv6/udp.c change.  Thanks!
>> I took them both into my tree.  Didn't you see my reply?
> 
> I did, but I didn't see the change yet in .39-rc5, so I figured it would be
> harmless to also take it into the tile tree.

This change will show up in net-next-2.6 and as a consequence linux-2.6-next
