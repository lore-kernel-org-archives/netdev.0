From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 0/2] [BUG FIXES - 3.10.27] sit: More backports
Date: Thu, 30 Jan 2014 17:10:29 -0500
Message-ID: <20140130171029.01cd80ca@gandalf.local.home>
References: <20140128205756.074448668@goodmis.org>
	<52E8E025.2060803@6wind.com>
	<20140129075745.4227a2ed@gandalf.local.home>
	<52E9267C.90403@6wind.com>
	<20140129154811.27fbaf13@gandalf.local.home>
	<52EA1B4B.5080403@6wind.com>
	<20140130083103.2bc68bad@gandalf.local.home>
	<52EA56E1.40507@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable <stable@vger.kernel.org>,
	Clark Williams <williams@redhat.com>,
	"Luis Claudio R. Goncalves" <lclaudio@uudg.org>,
	John Kacur <jkacur@redhat.com>,
	Willem de Bruijn <willemb@google.com>
To: nicolas.dichtel@6wind.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52EA56E1.40507@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Jan 2014 14:42:57 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:


> > I'll let you know when these are finished.
> Thank you for testing.

Our short tests that were crashing have all now passed :-) with your
patches applied.

We are now running our full tier tests on the code, but I don't think
we need to wait. Please add my tags to your patches, and hopefully we
can get David to give us a new blessing on your patch set.

David and Greg,

You can ignore my patches as it seems that Nicolas's patches solve the
issues we have been seeing on 3.10.

Nicolas,

Thanks for all your effort in helping us out here :-)

Reported-by: Steven Rostedt <srostedt@redhat.com>
Tested-by: Steven Rostedt <srostedt@redhat.com> (and our entire MRG team)
Tested-by: "Luis Claudio R. Goncalves" <lgoncalv@redhat.com>
Tested-by: John Kacur <jkacur@redhat.com>

I don't usually give my Red Hat email for things like this, but as this
was found and tested with the Red Hat infrastructure, with the help
from Luis and John (and others), I would like to give them credit too.

-- Steve
