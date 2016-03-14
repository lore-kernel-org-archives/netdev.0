From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] net: thunderx: Performance enhancement changes
Date: Mon, 14 Mar 2016 12:33:55 -0400 (EDT)
Message-ID: <20160314.123355.932808497910918919.davem@davemloft.net>
References: <1457953578-7054-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com,
	robert.richter@caviumnetworks.com
To: sunil.kovvuri@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457953578-7054-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: sunil.kovvuri@gmail.com
Date: Mon, 14 Mar 2016 16:36:13 +0530

> Below patches attempts to improve performance by reducing
> no of atomic operations while allocating new receive buffers
> and reducing cache misses by adjusting nicvf structure elements.
> 
> Changes from v1:
>  No changes, resubmitting a fresh as per David's suggestion.

Series applied, thanks.
