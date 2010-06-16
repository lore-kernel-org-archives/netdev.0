From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Wed, 16 Jun 2010 08:16:10 +0200
Message-ID: <1276668970.19249.60.camel@edumazet-laptop>
References: <20100610145915.721a86b7@nehalam>
	 <20100610224839.GA22469@gondor.apana.org.au>
	 <20100611021142.GA24490@gondor.apana.org.au>
	 <20100615.113940.245399246.davem@davemloft.net>
	 <1276657139.19249.50.camel@edumazet-laptop>
	 <1276657400.19249.53.camel@edumazet-laptop>
	 <20100616033336.GA17440@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	shemminger@vyatta.com, mst@redhat.com, frzhang@redhat.com,
	netdev@vger.kernel.org, amwang@redhat.com, mpm@selenic.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:49689 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756024Ab0FPGQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 02:16:16 -0400
Received: by wwb18 with SMTP id 18so5358027wwb.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 23:16:14 -0700 (PDT)
In-Reply-To: <20100616033336.GA17440@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 juin 2010 =C3=A0 13:33 +1000, Herbert Xu a =C3=A9crit :
> On Wed, Jun 16, 2010 at 05:03:20AM +0200, Eric Dumazet wrote:
> >
> > I wonder how these patches were tested, Herbert ?
>=20
> You know, not everyone enables RCU debugging...
>=20

Hmm, this was not an attack Herbert, just a suggestion, I now turn on
RCU lockdep debugging when doing RCU changes, it can helps ;)

> Anyway, this patch should fix the problems you've spotted.
>=20

Thanks

