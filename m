From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] Move generic encap code into xfrm4_output
Date: Sat, 10 Jul 2004 12:02:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040710120201.0decc8ac.davem@redhat.com>
References: <20040710005146.GA11023@gondor.apana.org.au>
	<Xine.LNX.4.44.0407100233170.6775-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0407100233170.6775-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 10 Jul 2004 02:34:36 -0400 (EDT)
James Morris <jmorris@redhat.com> wrote:

> On Sat, 10 Jul 2004, Herbert Xu wrote:
> 
> > Hi:
> > 
> > I've finally finished merging the general encapsulation code for IPv4.
> > Here is the patch.
> 
> This looks fine to me so far, also tests ok with various tunneled 
> configurations.

Looks good to me too.  Applied, thanks Herbert.
