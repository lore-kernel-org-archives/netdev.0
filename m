From: Patrick McHardy <kaber@trash.net>
Subject: Re: pppoe: fix compiler warning
Date: Wed, 25 Jun 2008 02:11:21 +0200
Message-ID: <48618D29.5020805@trash.net>
References: <48611A06.9070607@trash.net> <20080624.133547.14143189.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35532 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbYFYAL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 20:11:28 -0400
In-Reply-To: <20080624.133547.14143189.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue, 24 Jun 2008 18:00:06 +0200
> 
>> pppoe: fix compiler warning
>>
>> Fix warning introduced by 392fdb0 (net pppoe: Check packet length on all receive paths):
>>
>> drivers/net/pppoe.c: In function 'pppoe_recvmsg':
>> drivers/net/pppoe.c:945: warning: comparison of distinct pointer types lacks a cast
>>
>> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Should already be fixed in net-2.6 by:

My mistake, sorry :)



