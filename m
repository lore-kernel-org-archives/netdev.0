From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: Add missing include of linux/slab.h
Date: Mon, 26 Dec 2011 15:19:36 -0500 (EST)
Message-ID: <20111226.151936.1114579002330233726.davem@davemloft.net>
References: <1324892134.9765.1.camel@phoenix>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, yevgenyp@mellanox.co.il,
	jackm@dev.mellanox.co.il, marcela@dev.mellanox.co.il,
	eugenia@mellanox.co.il, netdev@vger.kernel.org
To: axel.lin@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324892134.9765.1.camel@phoenix>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Axel Lin <axel.lin@gmail.com>
Date: Mon, 26 Dec 2011 17:35:34 +0800

> Include linux/slab.h to fix below build error:

You make no indication whatsoever what source tree you see this
error in.

By trial and error I figured out that your patch only applies to
the net-next tree, so I added it there.

But I should not have to go through such a sequence just to figure out
what tree your patch is for, so please indicate this properly in the
future.
