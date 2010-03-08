From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6] netfilter: Remove stale declaration for ip6_masked_addrcmp().
Date: Mon, 08 Mar 2010 13:14:36 +0100
Message-ID: <4B94EA2C.5010709@trash.net>
References: <201003070918.o279IfCk029612@94.43.138.210.xn.2iij.net> <20100307.152719.53364949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45647 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755090Ab0CHMOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 07:14:38 -0500
In-Reply-To: <20100307.152719.53364949.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Sun, 7 Mar 2010 17:39:13 +0900
> 
>> Commit f2ffd9ee... ("[NETFILTER]: Move ip6_masked_addrcmp to
>> include/net/ipv6.h") replaced ip6_masked_addrcmp() with
>> ipv6_masked_addr_cmp().  Function definition went away.
>>
>> Let's remove its declaration as well in header file.
>>
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Patrick, I assume you'll get this one too.

I will, thanks.
