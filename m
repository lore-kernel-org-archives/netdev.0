From: Matt Mackall <mpm@selenic.com>
Subject: Re: Parentage of BPF code in Linux
Date: Thu, 1 Jul 2004 13:43:55 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040701184354.GJ5414@waste.org>
References: <20040701181002.GG6445@sparky.finchhaven.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Sage <jsage@finchhaven.com>
Content-Disposition: inline
In-Reply-To: <20040701181002.GG6445@sparky.finchhaven.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 01, 2004 at 11:10:02AM -0700, John Sage wrote:
> [Non-subscriber: please cc on replies]
> 
> WRT to the SCO/IBM/Linux imbroglio, there was an interesting assertion
> made on the Yahoo! Finance message board for SCOX, and I wondered if
> anyone could shed some light.
> 
> The assertion is this:
> 
> "...among other things, the Berkeley Packet Filter code, which was
> written by an independent developer for the Missouri School District,
> licensed under the BSD license terms that never was part of SysV at
> any time..."

There's a from-scratch reimplementation of BPF in Linux (called Linux
Socket Filter) by Jay Schulist in net/core/filter.c. And he appears to
have worked for the _Wisconsin_ school district at the time. A Google
search on "schulist filter wisconsin" reveals:

  Jay Schulist, a senior software engineer with Pleasanton,
  California's Bivio Networks says he wrote the 500 lines of code in
  1997 as part of a volunteer project for the Stevens Point Area
  Catholic Schools in Wisconsin. "I used it for helping a local school
  district in my home town to connect their old Apple Macintosh machines
  to the Internet," he said.

-- 
Mathematics is the supreme nostalgia of our time.
