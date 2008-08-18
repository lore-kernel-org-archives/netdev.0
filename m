From: Patrick McHardy <kaber@trash.net>
Subject: Re: csum offload and af_packet
Date: Mon, 18 Aug 2008 13:17:58 +0200
Message-ID: <48A95A66.4030506@trash.net>
References: <48A2C4DE.20005@trash.net>	<20080817.160825.22400712.davem@davemloft.net>	<48A8CCBF.3020408@trash.net> <20080817.191224.118214583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@axxeo.de,
	rusty@rustcorp.com.au, anthony@codemonkey.ws,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51846 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbYHRLSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 07:18:03 -0400
In-Reply-To: <20080817.191224.118214583.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 18 Aug 2008 03:13:35 +0200
> 
>> the linux support looks a lot cleaner in general
> 
> I totally disagree after having looked at this thing.

You should have seen the old mmaped packet socket support :)
But I agree, it certainly could be done cleaner.
