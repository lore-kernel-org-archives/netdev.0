From: James Morris <jmorris@redhat.com>
Subject: Re: [IPSEC] Move generic encap code into xfrm4_output
Date: Sat, 10 Jul 2004 02:34:36 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0407100233170.6775-100000@thoron.boston.redhat.com>
References: <20040710005146.GA11023@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040710005146.GA11023@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 10 Jul 2004, Herbert Xu wrote:

> Hi:
> 
> I've finally finished merging the general encapsulation code for IPv4.
> Here is the patch.

This looks fine to me so far, also tests ok with various tunneled 
configurations.


- James
-- 
James Morris
<jmorris@redhat.com>
