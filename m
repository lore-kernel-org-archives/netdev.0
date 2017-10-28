From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] ipv6: exthdrs: use swap macro in ipv6_dest_hao
Date: Sat, 28 Oct 2017 19:07:21 +0900 (KST)
Message-ID: <20171028.190721.904336719839639001.davem@redhat.com>
References: <20171027041002.GA13506@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027041002.GA13506@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Thu, 26 Oct 2017 23:10:35 -0500

> make use of the swap macro and remove unnecessary variable tmp_addr.
> This makes the code easier to read and maintain.
> 
> This code was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied to net-next, thanks.
