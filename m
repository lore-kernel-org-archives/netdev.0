From: Kristen Carlson <kristenc@cs.pdx.edu>
Subject: Re: patricia tries vs. hash for routing?
Date: Fri, 19 Sep 2003 14:48:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030919214837.GA3012@sirius.cs.pdx.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I was looking through some very old mail list discussions (1996!) on this 
topic, and the feeling then was that the code was optimal for < 60,000 routes.
Given that much has happened since then, is it still a fair assumption to say
that the linux routing algorithm is optimized for < 60,000 routes, but a
more BSD-like algorithm works better for > 60,000 routes?
Thanks,
Kristen
