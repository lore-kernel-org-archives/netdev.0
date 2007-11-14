From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 19/24] [IPSEC]: Merge most of the output path
Date: Wed, 14 Nov 2007 10:19:26 +0100
Message-ID: <473ABD9E.1040409@trash.net>
References: <E1Ipla8-0001IO-00@gondolin.me.apana.org.au> <4732F1B1.204@trash.net> <20071108112921.GB16688@gondor.apana.org.au> <20071114.010722.141237256.davem@davemloft.net> <473ABC73.30807@trash.net> <20071114091642.GA12711@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38707 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807AbXKNJTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 04:19:36 -0500
In-Reply-To: <20071114091642.GA12711@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Wed, Nov 14, 2007 at 10:14:27AM +0100, Patrick McHardy wrote:
>> Thanks Dave. As luck would have it, my HIFN card should arrive
>> within the next few hours, so I'll try to convert esp over to
>> async crypto and give this all some good testing :)
> 
> Actually I'm already working on that :)
> 
> I'm not just converting ESP over to async, I'm also changing
> it to use the AEAD interface which is needed for it to properly
> support algorithms such as CCM.


Great. If you're looking for testers, just send it over :)
