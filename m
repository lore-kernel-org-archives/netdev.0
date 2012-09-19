From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: do not disable sg for AoE
Date: Wed, 19 Sep 2012 16:00:09 -0400 (EDT)
Message-ID: <20120919.160009.1489407274317336389.davem@davemloft.net>
References: <1348079358.4585@cat.he.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jesse@nicira.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ecashin@coraid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348079358.4585@cat.he.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Date: Tue, 18 Sep 2012 20:20:36 -0400

Please do not incorporate the date of the commit in your local tree
into the Date: field advertised in your outgoing emails when you post
patches.

You did not post this on September 18th, you posted it on September
19th.

When you post patches the way you did, it screws up the ordering
of my patch queue at:

	http://patchwork.ozlabs.org/project/netdev/list/

since it is sorted by the Date: in the patch's email.

Therefore if you just use the normal email posting date it makes
my life a lot easier and it makes sure patches will be looked at
and processed in the correct order.

Thanks.
