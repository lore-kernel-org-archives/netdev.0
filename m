From: James Morris <jmorris@redhat.com>
Subject: Re: [IPCOMP6] Fix ICMP type check
Date: Thu, 22 Jul 2004 10:25:24 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0407221025010.7557@devserv.devel.redhat.com>
References: <20040722113429.GA15083@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040722113429.GA15083@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 22 Jul 2004, Herbert Xu wrote:

> Hi Dave:
> 
> It looks like IPCOMP was missed when the same problem was fixed in AH/ESP.

What about esp4/ah4/ipcomp?  They look wrong too.


- James
-- 
James Morris
<jmorris@redhat.com>
