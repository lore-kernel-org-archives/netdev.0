From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Mon, 18 Feb 2013 20:30:18 -0500 (EST)
Message-ID: <20130218.203018.1503258377581298518.davem@davemloft.net>
References: <20130219121722.c5470cdd2040712deb8e8043@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	r.kuntz@ipflavors.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130219121722.c5470cdd2040712deb8e8043@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 19 Feb 2013 12:17:22 +1100

> I assume that the problem fixed by the net tree commit is fixed some
> other way in the net-next tree, so I reverted the net tree commit.

The net tree commit should be simply reverted, yes.
