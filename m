From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Fri, 23 May 2003 02:59:06 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030523.025906.108797803.davem@redhat.com>
References: <20030523102113.4fe38159.ak@suse.de>
	<20030523.012205.123984853.davem@redhat.com>
	<20030523110301.25b95026.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gandalf@wlug.westbo.se, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: ak@suse.de
In-Reply-To: <20030523110301.25b95026.ak@suse.de>
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Fri, 23 May 2003 11:03:01 +0200

   On Fri, 23 May 2003 01:22:05 -0700 (PDT)
   "David S. Miller" <davem@redhat.com> wrote:
   
   > Then what does that comment above it mean? :-)
   
   I guess it refers to the implementation, not the code.

Ok, I fixed the fib_hash.c stuff to use get_order().
