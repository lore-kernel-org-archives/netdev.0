From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_bbr: fix Kconfig to be able to make BBR the
 default congestion algorithm
Date: Wed, 30 Nov 2016 22:43:37 -0500 (EST)
Message-ID: <20161130.224337.1171980480771762847.davem@davemloft.net>
References: <b37e4220-b857-4853-f2e2-b77bb08115e5@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        ncardwell@google.com
To: berny156@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b37e4220-b857-4853-f2e2-b77bb08115e5@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernhard Held <berny156@gmx.de>
Date: Wed, 30 Nov 2016 23:31:29 +0100

> Add missing line to be able to make BBR the default
> congestion algorithm.
> 
> Signed-off-by: Bernhard Held <berny156@gmx.de>

The current tree already has this fix.
