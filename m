From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: netlink tester program
Date: Fri, 30 May 2003 09:00:15 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030530090015.7c435c9a.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi--

I tried to write a simple test program for (rt)netlink, but I didn't
succeed I'm sorry to say.  Does anyone have one or know of one?
[alternative plan is to use kgdb to determine why my test program
is failing...]

I think it should be possible in around 100 lines of code.
I don't want to use iproute2 and libnetlink -- they are much larger
and more complex than a syscall interface test program should be.

I've asked Alexey but I'm getting no replies from him.

Thanks,
--
~Randy
