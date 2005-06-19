From: Matt Mackall <mpm@selenic.com>
Subject: Re: netpoll and the bonding driver
Date: Sun, 19 Jun 2005 11:14:36 -0700
Message-ID: <20050619181436.GX27572__33355.0185816877$1119205115$gmane$org@waste.org>
References: <17075.10995.498758.773092@segfault.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Moyer <jmoyer@redhat.com>
Content-Disposition: inline
In-Reply-To: <17075.10995.498758.773092@segfault.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jun 17, 2005 at 03:56:35PM -0400, Jeff Moyer wrote:
> Hi,
> 
> I'm trying to implement a netpoll hook for the bonding driver.

My first question would be: does this really make sense to do? Why not
just bind netpoll to one of the underlying devices?

-- 
Mathematics is the supreme nostalgia of our time.
