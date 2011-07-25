From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Convert struct net_device uc_promisc to
 bool
Date: Mon, 25 Jul 2011 16:17:43 -0700 (PDT)
Message-ID: <20110725.161743.1867021302415399607.davem@davemloft.net>
References: <813214b21d4db8d08a76c648ea1d3286b441b706.1311604594.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <813214b21d4db8d08a76c648ea1d3286b441b706.1311604594.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 25 Jul 2011 07:41:26 -0700

> No need to use int, its uses are boolean.
> May save a few bytes one day.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
