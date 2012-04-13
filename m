From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: linux-next: Tree for Apr 12
Date: Fri, 13 Apr 2012 13:11:45 +0100
Message-ID: <20120413131145.1fd00f1d@pyramind.ukuu.org.uk>
References: <20120412145931.9ec6f2b51655071795d60d1d@canb.auug.org.au>
	<20120412142415.564710b8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120412142415.564710b8.akpm@linux-foundation.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Apr 2012 14:24:15 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 12 Apr 2012 14:59:31 +1000
> Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> 
> > I have created today's linux-next tree at
> > git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
> 
> This isn't working for me.  Some time between April 3 and April 12
> someone merged something into the non-mm part of linux-next which broke
> ssh.

You are getting further than me  - on 32bit -next of the 12th explodes
with random userspace crashes in init or similar early code.

Alan
