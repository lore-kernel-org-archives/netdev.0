From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: net/core/flow.c cpu handling?
Date: Mon, 03 Nov 2003 21:26:40 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031103102829.E1C622C05E@lists.samba.org>
References: <20031101225050.4de96a8b.davem@redhat.com>
Cc: anton@samba.org, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Sat, 01 Nov 2003 22:50:50 -0800."
             <20031101225050.4de96a8b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20031101225050.4de96a8b.davem@redhat.com> you write:
> 
> Very likely, the code is how it is in order to make the
> 2.4.x backport of this code and the 2.6.x version as
> similar as humanly possible.

Hmm, AFAICT the patch I sent should be easier, not harder to backport.

Anyway, I'm carrying the patch as part of the hotplug CPU patches: we
can discuss it once 2.6.0 is out.

Thanks,
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
