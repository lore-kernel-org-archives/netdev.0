From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: freescale: fix potential null pointer dereference
Date: Wed, 31 May 2017 14:24:28 -0400 (EDT)
Message-ID: <20170531.142428.2266848627780174653.davem@davemloft.net>
References: <20170530223842.GA11915@embeddedgus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170530223842.GA11915@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Tue, 30 May 2017 17:38:43 -0500

> Add NULL check before dereferencing pointer _id_ in order to avoid
> a potential NULL pointer dereference.
> 
> Addresses-Coverity-ID: 1397995
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied, thanks.
