From: James Morris <jmorris@redhat.com>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 21:43:41 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0409152142250.685-100000@thoron.boston.redhat.com>
References: <Pine.NEB.4.33.0409151918320.9172-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netdev <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0409151918320.9172-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004, John Heffner wrote:

> > Do you have any figures on (large) MTU size vs performance on a current
> > commidity system?
> 
> What qualifies as large?  I ran some measurements out to 9k w/GigE a few
> years ago.  (Something like 100 byte increments.)  I can try to find the
> data if anyone is interested.  I may try to run a similar experiment on 10
> GigE with modern hardware, and I think these cards can go out to 16k as
> well.

Anything above 1500 bytes (up to 64k would be interesting).

> There are some arguments that going to much larger MTUs could be of
> substantial benefit other than CPU cycles, but this is harder to quantify.
> See <http://www.psc.edu/~mathis/MTU/>.

Thanks for the info.


- James
-- 
James Morris
<jmorris@redhat.com>
