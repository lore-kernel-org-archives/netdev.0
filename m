From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: disablenetwork() syscall?
Date: Mon, 7 Jul 2003 19:33:35 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030707223334.GG5292@conectiva.com.br>
References: <20030707194657.GA11328@gtf.org> <Pine.LNX.4.44.0307072250000.11843-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0307072250000.11843-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Mon, Jul 07, 2003 at 10:52:15PM +0300, Pekka Savola escreveu:
> On Mon, 7 Jul 2003, Jeff Garzik wrote:
> > On Mon, Jul 07, 2003 at 10:40:02PM +0300, Pekka Savola wrote:
> > > In a bugtraq thread, DJ Bernstein brought up an idea which I'm not sure 
> > > has been brought up in the past.  I'm not sure whether it's feasible or 
> > > not, but at least it (and other methods to limit the functions of a 
> > > user-level code) might bear consideration.
> > 
> > What about some URLs to what you are describing?
> > 
> > The most information you provided was in $subject, whose content
> > makes me a bit leery...
> 
> Well, apart from the post scriptum, there was very little content about 
> the feature/idea :-), and the details would seem to be up for everyone's 
> imagination. 
> 
> FWIW, the body of the message is below:

Incomplete, here is the part that he mention the disablenetwork syscall:

------------------------------------- 8< ------------------------------

P.S. It's hard for a portable chroot tool to cut off a program's network
access. Kernel designers should provide a disablenetwork() syscall, with
the disabling inherited by children. Other kernel changes would be nice,
but disablenetwork() is the only critical change.

------------------------------------- 8< ------------------------------
