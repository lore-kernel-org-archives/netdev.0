From: Kristen Carlson <kristenc@cs.pdx.edu>
Subject: linux 2.4 routing algorithm?
Date: Wed, 17 Sep 2003 16:47:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030917234753.GB11250@sirius.cs.pdx.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
I'm trying to understand the routing algorithm for linux 2.4.  I thought
it would use a longest prefix match due to some documentation I had googled,
but the code in route.c looks like a hash.  I probably just don't understand
how lpm would be coded in practice.  Am I looking in the right place?  Can
someone give me a clue about how this works?

Thanks,
Kristen

-- 
WWXD (What Would Xena Do?) 
