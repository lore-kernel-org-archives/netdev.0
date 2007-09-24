From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] sb1250-mac: Driver model & phylib update
Date: Mon, 24 Sep 2007 09:55:59 -0700
Message-ID: <20070924095559.c81f7061.akpm@linux-foundation.org>
References: <Pine.LNX.4.64N.0709191811040.24627@blysk.ds.pg.gda.pl>
	<20070921124409.7f3d122b.akpm@linux-foundation.org>
	<Pine.LNX.4.64N.0709241529570.22491@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <Pine.LNX.4.64N.0709241529570.22491@blysk.ds.pg.gda.pl>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Mon, 24 Sep 2007 15:41:54 +0100 (BST) "Maciej W. Rozycki" <macro@linux-mips.org> wrote:

> On Fri, 21 Sep 2007, Andrew Morton wrote:
> 
> > >  A driver model and phylib update.
> > 
> > akpm:/usr/src/25> diffstat patches/git-net.patch | tail -n 1
> >  1013 files changed, 187667 insertions(+), 23587 deletions(-)
> > 
> > Sorry, but raising networking patches against Linus's crufty
> > old mainline tree just isn't viable at present.
> 
>  Well, this is against Jeff's netdev-2.6 tree which hopefully is not as 
> crufty as Linus's old mainline; if it is not possible to queue this change 
> for 2.6.25 or suchlike, then I will try to resubmit later.

Most of Jeff's netdev tree got dumped into Dave's net-2.6.24 tree.  That's
the one you want to be raising patches against for the next few weeks.
