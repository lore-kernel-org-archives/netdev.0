From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.46-mm1 3 uninitialized timers during boot, ipv6 related?
Date: Wed, 06 Nov 2002 08:57:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DC94A01.1ADC918E@digeo.com>
References: <3DC8D423.DAD2BF1A@digeo.com> <3DC9192E.62600E21@aitel.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@redhat.com, kuznet@ms2.inr.ac.ru,
   pekkas@netcore.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Helge Hafting <helgehaf@aitel.hist.no>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Helge Hafting wrote:
> 
> I see these aren't dangerous, but I guess they're there for
> someone to see.  So here they are.
> Seems they have something to do with ipv6.
> 

Dave has a bunch of additional fixes for net/*.  Expect them to emerge
from kernel.org real soon.
