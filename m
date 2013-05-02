From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Thu, 02 May 2013 13:58:56 -0400 (EDT)
Message-ID: <20130502.135856.2001406508082430880.davem@davemloft.net>
References: <20130502070256.GA29502@macbook.localnet>
	<20130502.041625.412316202038784117.davem@davemloft.net>
	<20130502083619.GA22010@macbook.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, hayeswang@realtek.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130502083619.GA22010@macbook.localnet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 2 May 2013 10:36:49 +0200

> commit d0ed96507b21da2668766207f68518bef3193111
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Thu May 2 10:35:02 2013 +0200
> 
>     net: use netdev_features_t in skb_needs_linearize()
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied and queued up for -stable, thanks.
