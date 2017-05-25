From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix potential null pointer dereference
Date: Thu, 25 May 2017 12:54:28 -0400 (EDT)
Message-ID: <20170525.125428.743684247535321797.davem@davemloft.net>
References: <20170523231837.GA9364@embeddedgus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, laforge@gnumonks.org,
        osmocom-net-gprs@lists.osmocom.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170523231837.GA9364@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Tue, 23 May 2017 18:18:37 -0500

> Add null check to avoid a potential null pointer dereference.
> 
> Addresses-Coverity-ID: 1408831
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied, thank you.
