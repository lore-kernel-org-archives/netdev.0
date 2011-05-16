From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Mon, 16 May 2011 14:24:19 +0200
Message-ID: <BANLkTi=7i=AQfPNBEGcLFieaO9wXgBk6rg@mail.gmail.com>
References: <20110505084428.GB17647@redhat.com> <4DC26F33.8010700@cn.fujitsu.com>
 <20110505100506.GA20111@gondor.apana.org.au> <20110516073210.GB6610@redhat.com>
 <20110516080702.GA1857@gondor.apana.org.au> <20110516081841.GA8073@redhat.com>
 <20110516093822.GA2779@gondor.apana.org.au> <20110516094821.GA9427@redhat.com>
 <20110516104309.GA3534@gondor.apana.org.au> <20110516112133.GA11274@redhat.com>
 <20110516121857.GA4495@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Shan Wei <shanwei@cn.fujitsu.com>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:45316 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364Ab1EPMYk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 08:24:40 -0400
Received: by qyg14 with SMTP id 14so2578918qyg.19
        for <netdev@vger.kernel.org>; Mon, 16 May 2011 05:24:39 -0700 (PDT)
In-Reply-To: <20110516121857.GA4495@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/16 Herbert Xu <herbert@gondor.apana.org.au>:
> On Mon, May 16, 2011 at 02:21:33PM +0300, Michael S. Tsirkin wrote:
>> Yes, but then we get annoying info messages every time.
>> Change them all to debug or remove completely?
> If you are getting warning messages then it probably means that
> your driver is doing something wrong.

In this case - no. Those messages inform that driver supports more
feature combinations than network core and the feature set is reduced
because of that.

Best Regards,
Micha=C5=82 Miros=C5=82aw
