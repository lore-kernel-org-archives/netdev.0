From: Matt Mathis <mathis@psc.edu>
Subject: Web100
Date: Mon, 4 Aug 2003 12:20:47 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308041205181.27601-100000@zippy.psc.edu>
References: <20030803222554.7027a160.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, John Heffner <jheffner@psc.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030803222554.7027a160.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 3 Aug 2003, David S. Miller wrote:
> The web100 patches aren't in the kernel because 1) they've
> never even been submitted and 2) they need a large cleanup.

Furthermore 1 is due to 2....  We know our code is not ready for kernel
inclusion, and are having a little trouble seeing the path through to doing so
ourselves.  A big part of the problem is that I an not a kernel guy - my focus
in on the protocol and measurement issues and not on the implementation
details.  Although John could probably get it together by himself, he is split
between several projects and it isn't clear that incrementally submitting
substandard patches is a cost effective strategy to getting it done.

It would be a lot easier if we 1) had a mentor who was experienced at kernel
inclusion, 2) specific guidance on some of the non-network components, such as
the API (currently using /proc) and 3) a laundry list of things that we need to
fix.

> I sort of get the impression that the web100 folks actually like that
> their changes are not in the main sources, it keeps their work
> "special".

Nope, not at all.  Actually I find kernel inclusion rather daunting.  One of
our collaborators was asked some very pointed questions about the TCP ESTATS
MIB by somebody at M$.  I would hate to have the first general release be in
anything but Linux.

Any takers on helping us?

Thanks,
--MM--
-------------------------------------------
Matt Mathis      http://www.psc.edu/~mathis
Work:412.268.3319    Home/Cell:412.654.7529
-------------------------------------------
