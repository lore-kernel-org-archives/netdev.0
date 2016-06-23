From: David Miller <davem@davemloft.net>
Subject: Re: esp: Fix ESN generation under UDP encapsulation
Date: Thu, 23 Jun 2016 11:52:45 -0400 (EDT)
Message-ID: <20160623.115245.451201603985254809.davem@davemloft.net>
References: <20160620105934.GL7698@gauss.secunet.com>
	<576B64B1.9030000@alliedtelesis.co.nz>
	<20160623104007.GO7698@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Blair.Steven@alliedtelesis.co.nz, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbcFWPwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 11:52:51 -0400
In-Reply-To: <20160623104007.GO7698@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 23 Jun 2016 12:40:07 +0200

> On Thu, Jun 23, 2016 at 04:25:21AM +0000, Blair Steven wrote:
>> This change tests okay in my setup.
>> 
>> Thanks very much
>> -Blair
> 
> David, can you please take this patch directly in the net tree?
> This is a candidate for stable.
> 
> Acked-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied, thanks everyone.

Does the ipv6 side need the same fix?
