From: John Sage <jsage@finchhaven.com>
Subject: Re: Parentage of BPF code in Linux
Date: Thu, 1 Jul 2004 11:55:55 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040701185555.GH6445@sparky.finchhaven.net>
References: <20040701181002.GG6445@sparky.finchhaven.net> <20040701184354.GJ5414@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266233AbUGAS7C@vger.kernel.org>
To: Matt Mackall <mpm@selenic.com>
Content-Disposition: inline
In-Reply-To: <20040701184354.GJ5414@waste.org>
List-Id: netdev.vger.kernel.org

Matt:

On Thu, Jul 01, 2004 at 01:43:55PM -0500, Matt Mackall wrote:
> Date: Thu, 1 Jul 2004 13:43:55 -0500
> From: Matt Mackall <mpm@selenic.com>
> To: John Sage <jsage@finchhaven.com>
> Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
> Subject: Re: Parentage of BPF code in Linux
> User-Agent: Mutt/1.3.28i
> 
> On Thu, Jul 01, 2004 at 11:10:02AM -0700, John Sage wrote:
> > [Non-subscriber: please cc on replies]
> > 
> > WRT to the SCO/IBM/Linux imbroglio, there was an interesting
> > assertion made on the Yahoo! Finance message board for SCOX, and I
> > wondered if anyone could shed some light.
> > 
> > The assertion is this:
> > 
> > "...among other things, the Berkeley Packet Filter code, which was
> > written by an independent developer for the Missouri School
> > District, licensed under the BSD license terms that never was part
> > of SysV at any time..."
> 
> There's a from-scratch reimplementation of BPF in Linux (called
> Linux Socket Filter) by Jay Schulist in net/core/filter.c. And he
> appears to have worked for the _Wisconsin_ school district at the
> time. A Google search on "schulist filter wisconsin" reveals:
> 
>   Jay Schulist, a senior software engineer with Pleasanton,
>   California's Bivio Networks says he wrote the 500 lines of code in
>   1997 as part of a volunteer project for the Stevens Point Area
>   Catholic Schools in Wisconsin. "I used it for helping a local
>   school district in my home town to connect their old Apple
>   Macintosh machines to the Internet," he said.

Interesting.

Thank you.

And there it is:

/*
 * Linux Socket Filter - Kernel level socket filtering
 *
 * Author:
 *     Jay Schulist <jschlst@samba.org>
 *
 * Based on the design of:
 *     - The Berkeley Packet Filter

/* snip */


The only other reference I've been able to find to this "Missouri
School District/BPF" meme was in a post to a ZDNet message board back
in November, 2003...


- John
-- 
10 print "Home"
20 print "Sweet"
30 goto 10
