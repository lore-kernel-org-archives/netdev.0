From: "David S. Miller" <davem@redhat.com>
Subject: Re: netlink tester program
Date: Mon, 02 Jun 2003 20:35:05 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030602.203505.59678701.davem@redhat.com>
References: <20030602140452.039248de.rddunlap@osdl.org>
	<20030602.145619.71112623.davem@redhat.com>
	<33001.4.64.196.31.1054611142.squirrel@www.osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: rddunlap@osdl.org
In-Reply-To: <33001.4.64.196.31.1054611142.squirrel@www.osdl.org>
List-Id: netdev.vger.kernel.org

   From: "Randy.Dunlap" <rddunlap@osdl.org>
   Date: Mon, 2 Jun 2003 20:32:22 -0700 (PDT)

   The code is absolute, no doubt about it.  It is the authority.
   That doesn't make it right in all cases AFAIK.
   
I totally agree.

   Now, given that I think that the netlink interface is poorly
   documented, and that I'm trying to add some kernel code that
   uses it, and that I'm trying to test said kernel code with a
   userspace test program, I also plan to add such documentation
   that I think is warranted to make it easy to use, even by
   non-kernel devevlopers.

This is exactly how things should work.  Where there is a need
for X _AND_ someone willing to create X, it will be created.

No arguments from me on this :-)
