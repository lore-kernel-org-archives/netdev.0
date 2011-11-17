From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] Use ETH_ALEN
Date: Wed, 16 Nov 2011 20:35:27 -0500 (EST)
Message-ID: <20111116.203527.1216342714272524865.davem@davemloft.net>
References: <cover.1321472142.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1321472142.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 16 Nov 2011 11:38:01 -0800

> Remove other #defines and uses in favor of ETH_ALEN
> 
> Joe Perches (5):
>   ethernet: Convert MAC_ADDR_LEN uses to ETH_ALEN
>   ethernet: Convert ETHER_ADDR_LEN uses to ETH_ALEN
>   bna: Convert MAC_ADDRLEN uses to ETH_ALEN
>   amd8111e:  Convert ETH_ADDR_LEN uses to ETH_ALEN
>   ucc_geth: Convert ENET_NUM_OCTETS_PER_ADDRESS uses to ETH_ALEN

All applied, thanks Joe.
