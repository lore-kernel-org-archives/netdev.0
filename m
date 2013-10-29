From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netconsole: Convert to pr_<level>
Date: Tue, 29 Oct 2013 17:43:25 -0400 (EDT)
Message-ID: <20131029.174325.408252313215165.davem@davemloft.net>
References: <1382990001.8718.4.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382990001.8718.4.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 28 Oct 2013 12:53:21 -0700

> Use a more current logging style.
> 
> Convert printks to pr_<level>.
> 
> Consolidate multiple printks into a single printk to avoid
> any possible dmesg interleaving.  Add a default "event" msg
> in case the listed types are ever expanded.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
