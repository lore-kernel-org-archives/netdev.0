From: James Morris <jmorris@redhat.com>
Subject: Re: pskb change in dst->output
Date: Wed, 7 Jul 2004 21:19:11 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0407072118490.29115-100000@thoron.boston.redhat.com>
References: <20040708011100.GA31600@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040708011100.GA31600@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 8 Jul 2004, Herbert Xu wrote:

> I'm just a bit unsure whether the pskb change is needed in dst_output().

I'm looking into it now, it may not be after all.


- James
-- 
James Morris
<jmorris@redhat.com>
