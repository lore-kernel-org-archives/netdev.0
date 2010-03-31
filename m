From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
 policy->walk.dead
Date: Wed, 31 Mar 2010 09:32:36 -0400
Message-ID: <1270042356.26743.30.camel@bigi>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
	 <1270030626-16687-5-git-send-email-timo.teras@iki.fi>
	 <20100331110345.GC12845@gondor.apana.org.au>
	 <1270040773.26743.12.camel@bigi>
	 <20100331131131.GA13793@gondor.apana.org.au>
	 <20100331132622.GA13908@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:41864 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933319Ab0CaNck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 09:32:40 -0400
Received: by qyk9 with SMTP id 9so94239qyk.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 06:32:39 -0700 (PDT)
In-Reply-To: <20100331132622.GA13908@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-31 at 21:26 +0800, Herbert Xu wrote:


> In fact the previous behaviour is also consistent with RFC2367:

I did not touch pfkey. That behavior remains there. 

cheers,
jamal


