From: "J Chapman" <jchapman@katalix.com>
Subject: RE: single process pppd for all PPP sessions? [Was [IPCOMP] Use per-cpu buffers]
Date: Mon, 13 Sep 2004 12:18:39 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409131119.i8DBJSgn007059@oss.sgi.com>
References: <20040910111047.GA29330@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <kuznet@ms2.inr.ac.ru>, <jmorris@redhat.com>, <netdev@oss.sgi.com>,
        <linux-ppp@vger.kernel.org>, <paulus@samba.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Herbert Xu'" <herbert@gondor.apana.org.au>,
        "'David S. Miller'" <davem@davemloft.net>
In-Reply-To: <20040910111047.GA29330@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Re: anyone think of doing a single process PPP daemon managing all 
PPP sessions?

Yes, although nothing started yet. Still working on OpenL2TP...
http://openl2tp.sf.net/

-James

> -----Original Message-----
> From: Herbert Xu [mailto:herbert@gondor.apana.org.au] 
> Sent: 10 September 2004 12:11
> To: David S. Miller
> Cc: kuznet@ms2.inr.ac.ru; jmorris@redhat.com; netdev@oss.sgi.com;
linux-ppp@vger.kernel.org; paulus@samba.org
> Subject: Re: [IPCOMP] Use per-cpu buffers
> 
[snip]

> On a totally orthogonal topic, has any body thought of doing a PPP
> daemon like the IPsec daemons? That is, have one process that manages
> all PPP sessions.  This could be useful for large L2TP servers and
> alike.
>
