From: David Miller <davem@davemloft.net>
Subject: Re: recvmsg sleeping from invalid context
Date: Sun, 22 Jan 2012 14:37:28 -0500 (EST)
Message-ID: <20120122.143728.1710688129934394279.davem@davemloft.net>
References: <201201220854.59968.maciej.rutecki@gmail.com>
	<20120122.141006.530154674609252253.davem@davemloft.net>
	<201201222031.51116.maciej.rutecki@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl
To: maciej.rutecki@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201201222031.51116.maciej.rutecki@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maciej Rutecki <maciej.rutecki@gmail.com>
Date: Sun, 22 Jan 2012 20:31:51 +0100

> These entries are using for tracking regressions, for *all* kernel parts, 
> without any exception. I see no reason to treat someone differently. If netdev 
> provides any interface to tracking regressions, then show me it. But then why 
> you do not use one common tool for all kernel?

This mailing list is the tracking mechanism.

You can create whatever you want, but I can guarentee that the very
people who can actually move the bug forward and fix the problem will
look at it.

It's been like this for ages, Andrew Morton understands how we wish
to track bugs, and that we don't want to use bugzilla for that purpose.
