From: James Morris <jmorris@intercode.com.au>
Subject: Re: Tigon 3 driver & Netgear GA302T
Date: Thu, 25 Apr 2002 01:53:58 +1000 (EST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0204250152190.11349-100000@blackbird.intercode.com.au>
References: <m3662hnmug.fsf@trained-monkey.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Jes Sorensen <jes@wildopensource.com>
In-Reply-To: <m3662hnmug.fsf@trained-monkey.org>
List-Id: netdev.vger.kernel.org

On 24 Apr 2002, Jes Sorensen wrote:

> >>>>> "James" == James Morris <jmorris@intercode.com.au> writes:
> 
> James> Does the tg3 driver support the Netgear GA302T card (which I
> James> think uses the Altima AC1000 chip) ?
> 
> If it's the Altima then I guess so, otherwise I'd expect the 83820
> driver to run it.
> 

It appears to be the Altima, from the Freebsd cvs log comments & 
associated changes for their bge driver.

I'll be getting a couple of the cards on Friday and should find out pretty 
quickly after that.


- James
-- 
James Morris
<jmorris@intercode.com.au>
