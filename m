From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 16:20:07 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0505171612440.3335@linux.site>
References: <E1DYBED-0006wa-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dlstevens@us.ibm.com, rick.jones2@hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DYBED-0006wa-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 18 May 2005, Herbert Xu wrote:

> ....
> Such systems would be violating the spirit of RFC791 which says:
> 
>     The identification field is used to distinguish the fragments of one
>     datagram from those of another.  The originating protocol module of
>     an internet datagram sets the identification field to a value that
>     must be unique for that source-destination pair and protocol for the
>     time the datagram will be active in the internet system.
> 
> Are you aware of any extant systems that do this?
> ....

Are you aware of any (new) systems that _don't_ violate this? I 
wouldn't want to own one of them! 

--
Arthur
