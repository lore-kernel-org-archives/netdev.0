From: "David S. Miller" <davem@redhat.com>
Subject: Re: networking bugs and bugme.osdl.org
Date: Sat, 12 Jul 2003 22:22:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030712222222.01089864.davem@redhat.com>
References: <1056755336.5459.16.camel@dhcp22.swansea.linux.org.uk>
	<20030627.172123.78713883.davem@redhat.com>
	<1056827972.6295.28.camel@dhcp22.swansea.linux.org.uk>
	<20030628.150328.74739742.davem@redhat.com>
	<m2vfu765cx.fsf@tnuctip.rychter.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Rychter <jan@rychter.com>
In-Reply-To: <m2vfu765cx.fsf@tnuctip.rychter.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 12 Jul 2003 10:07:42 -0700
Jan Rychter <jan@rychter.com> wrote:

> Interesting you should think you're 'rewarding' people. I thought your
> goal was to have fun working on cool software and making it
> better. I also thought I had the same goal as a bug-reporter.
> 
> When I write software, I care about every bug report and consider people
> doing the reporting a very valuable resource.

The whole game changes when you are stretched as thinly
as I am.  Scaling becomes everything, and nitpicking through
vague and poorly composed bug reports is an absolute waste of
my time as networking subsystem maintainer.

If other people want to improve bug reports, put them into
a cute usable database, and munge them along, that's fine with
me.

But _I_ only want to work with things that make the best use
of my limited time.

To be frank and honest, I do things that interest _ME_.  And waddling
through poorly made bug reports is anything but interesting, in fact
it's frustrating work.  I'd rather implement a software 802.11 stack
or TCP Vegas implementation, THAT is what is a good use of my time
because of my knowledge of how all these kinds of things work in the
Linux networking.  I can do things overnight that would take others
weeks.

Having me pillage through a bug database is a poor use of my time and
capabilities.  And all of my time is spent reviewing patches and
dealing with the properly composed bug reports anyways, so even if I
enjoyed pillaging through badly made bug reports I couldn't.

People are assuming that just because _I_ don't want to work on the
bad bug reports that I think nobody should.  It's the exact opposite.

I can't force other people to do or not do things anyways, just like
everyone trying to somehow make it my "duty" to look at every single
bug report cannot force me to do that.
