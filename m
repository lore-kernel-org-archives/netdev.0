From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: Fix kcalloc parameters swapped
Date: Mon, 13 Feb 2012 16:02:40 -0500 (EST)
Message-ID: <20120213.160240.316262527803124385.davem@davemloft.net>
References: <1329095679.3066.1.camel@phoenix>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jackm@dev.mellanox.co.il,
	netdev@vger.kernel.org
To: axel.lin@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329095679.3066.1.camel@phoenix>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Axel Lin <axel.lin@gmail.com>
Date: Mon, 13 Feb 2012 09:14:39 +0800

> The first parameter should be "number of elements" and the second parameter
> should be "element size".
> 
> Signed-off-by: Axel Lin <axel.lin@gmail.com>

Applied.
