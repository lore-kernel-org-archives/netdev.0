From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/6] myri10ge - Second half of the driver
Date: Fri, 12 May 2006 10:31:02 +1000
Message-ID: <E1FeLYc-0000y4-00@gondolin.me.apana.org.au>
References: <4463CE71.1000205@myri.com>
Cc: shemminger@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:10505 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750729AbWELAbJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 May 2006 20:31:09 -0400
To: brice@myri.com (Brice Goglin)
In-Reply-To: <4463CE71.1000205@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin <brice@myri.com> wrote:
>
>> It is preferred to put function declarations on one line.
>>
>> static int mril10ge_open(struct net_device *dev)
> 
> Well, I have seen several threads about this in the archive, with some
> people against and some people pro. I personaly like grepping for the
> declaration of function using ^name.
> If this codingstyle is really required, I will do.

Yes this is the standard coding style used in Linux so please do.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
