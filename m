From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH]xfrm: fix perpetual bundles
Date: Sun, 28 Feb 2010 09:07:15 -0500
Message-ID: <1267366035.24915.24.camel@bigi>
References: <1267017564.3973.790.camel@bigi>
	 <20100225104029.GB3927@gauss.dd.secunet.de>
	 <1267103990.3973.942.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, nakam@linux-ipv6.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:35165 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968056Ab0B1OHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 09:07:23 -0500
Received: by vws10 with SMTP id 10so41035vws.19
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2010 06:07:22 -0800 (PST)
In-Reply-To: <1267103990.3973.942.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steffen,

Did you try the simple patch i posted? After contemplating
in the background i think it is the right thing to do.
Ive also fixed IPV6 side the same way.

cheers,
jamal
On Thu, 2010-02-25 at 08:19 -0500, jamal wrote:


> 
> Lets hear what other people have to say - but iam beginning to feel
> probably the change i posted is not so unreasonable since 0.0.0.0
> is INADDR_ANY.
> 
> cheers,
> jamal

