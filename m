From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] drivers/isdn/mISDN: Use printf extension %pV
Date: Tue, 16 Nov 2010 10:23:14 -0800 (PST)
Message-ID: <20101116.102314.260073530.davem@davemloft.net>
References: <cover.1289348757.git.joe@perches.com>
	<b7079ecc43454c8b8baaef07f8cf1c1756c2ce3e.1289348757.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, isdn@linux-pingi.de,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b7079ecc43454c8b8baaef07f8cf1c1756c2ce3e.1289348757.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue,  9 Nov 2010 16:35:16 -0800

> Using %pV reduces the number of printk calls and
> eliminates any possible message interleaving from
> other printk calls.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks.
