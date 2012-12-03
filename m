From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Sun, 02 Dec 2012 19:32:16 -0500 (EST)
Message-ID: <20121202.193216.395617646386891717.davem@davemloft.net>
References: <20121128.214732.1634269294133625782.davem@davemloft.net>
	<CA+55aFy1sa=D-DrWqNuvjrLW8J0Tw1+GbZhXv6VHTTTxXG_DMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFy1sa=D-DrWqNuvjrLW8J0Tw1+GbZhXv6VHTTTxXG_DMA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 2 Dec 2012 16:13:30 -0800

> David, Willy pointed me to the recent splice crash fix
> (do_tcp_sendpages and non-0-order pages). It's apparently easily
> user-triggerable.. Should I take the patch directly, or do you have a
> tree to pull. Don't want to make a release with a known oopser..

I have a tree to pull.  Coming in a few minutes.
