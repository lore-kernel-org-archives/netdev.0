From: Rob Landley <rob@landley.net>
Subject: Re: [GIT] Networking
Date: Tue, 09 Jul 2013 20:54:45 -0500
Message-ID: <1373421285.27613.36@driftwood>
References: <CA+55aFxbipsZFC2iQsVchstOP_7mR48sUbo96LEJ4kxtZWQDKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxbipsZFC2iQsVchstOP_7mR48sUbo96LEJ4kxtZWQDKQ@mail.gmail.com>
	(from torvalds@linux-foundation.org on Tue Jul  9 12:32:56 2013)
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/09/2013 12:32:56 PM, Linus Torvalds wrote:
> On Mon, Jul 8, 2013 at 7:29 PM, Rob Landley <rob@landley.net> wrote:
> >
> > Um, does that mean I should have cc'd you on the initmpfs patch  
> series
> > back before the merge window opened?
> 
> So I personally don't tend to care about that kind of patch-series -
> it doesn't really add new features to basic code unlike the polling
> changes.

I tried to be as non-intrusive as possible while mucking about with  
early boot code on all targets. :)

> But I suspect for something like that series, the people to
> cc are Al Viro and Hugh Dickins because they maintain vfs adn tmpfs
> respectively.. That said, I think neither really cares.deeply, and
> this looks like a "Andrew" patch-series if only because it's so random
> ;)

All three were cc'd by get_maintainer.pl, but none of 'em seem to have  
noticed.

The embedded community continues to have strange needs, but they make  
sense to us. (And oddly enough to the supercomputer folks, who are  
basically "embedded with money".)

Thanks,

Rob