From: Lamont Granquist <lamont@scriptkiddie.org>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Mon, 28 Jul 2003 21:48:52 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030728213933.F81299@coredump.scriptkiddie.org>
References: <Pine.LNX.3.96.1030728222606.21100A-100000@gatekeeper.tmr.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>,
   Carlos Velasco <carlosev@newipnet.com>, bloemsaa@xs4all.nl,
   marcelo@conectiva.com.br, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   layes@loran.com, torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Bill Davidsen <davidsen@tmr.com>
In-Reply-To: <Pine.LNX.3.96.1030728222606.21100A-100000@gatekeeper.tmr.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 28 Jul 2003, Bill Davidsen wrote:
> On Sun, 27 Jul 2003, David S. Miller wrote:
> > This particular case has been discussed to death in the past
> > and I really recommend people read up there before dragging this
> > out further.
>
> It will keep coming back because it's a real problem. I do agree that the
> hidden patch is not the desired way to solve the problem, but until there
> is a reasonable (not requiring a guru or large manual effort) solution
> people will keep bringing it up.

And it severely violates the principle of least surprise.  Its unfortunate
that this principle isn't more widely discussed and considered on lkml.
