From: "David S. Miller" <davem@redhat.com>
Subject: Re: net/core/flow.c cpu handling?
Date: Mon, 3 Nov 2003 14:45:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031103144521.0aec9ea3.davem@redhat.com>
References: <20031101225050.4de96a8b.davem@redhat.com>
	<20031103102829.E1C622C05E@lists.samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20031103102829.E1C622C05E@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 03 Nov 2003 21:26:40 +1100
Rusty Russell <rusty@rustcorp.com.au> wrote:

> In message <20031101225050.4de96a8b.davem@redhat.com> you write:
> > 
> > Very likely, the code is how it is in order to make the
> > 2.4.x backport of this code and the 2.6.x version as
> > similar as humanly possible.
> 
> Hmm, AFAICT the patch I sent should be easier, not harder to backport.
> 
> Anyway, I'm carrying the patch as part of the hotplug CPU patches: we
> can discuss it once 2.6.0 is out.

I intend to review your patch today, there is no justification
for the problems you've pointed out in this code regardless of
how difficult or easy fixing it makes a backport.
