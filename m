From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Vlan interface nuisance
Date: Mon, 2 Mar 2009 15:39:12 +0800
Message-ID: <20090302073912.GA17328@gondor.apana.org.au>
References: <49AB8784.609@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, davem@davemloft.net, kaber@trash.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44968 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750920AbZCBHjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 02:39:20 -0500
Content-Disposition: inline
In-Reply-To: <49AB8784.609@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen.hemminger@vyatta.com> wrote:
>
>> In any case, ip(8) allows you to set the name to whatever you
>> want at creation time.  So for those nostalgics you can still
>> use ethX.Y through ip.
>>   
> Yes but their is no indication as to which interface was just created.

You should be able to set the name at creation time.

The default is only used if you didn't specify an explicit name.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
