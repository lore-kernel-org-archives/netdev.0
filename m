From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: icmp: use BUG_ON instead of if condition
 followed by BUG
Date: Tue, 24 Oct 2017 18:45:11 +0900 (KST)
Message-ID: <20171024.184511.1159787001630524952.davem@davemloft.net>
References: <20171023180814.GA25198@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171023180814.GA25198@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Mon, 23 Oct 2017 13:08:14 -0500

> Use BUG_ON instead of if condition followed by BUG in icmp_timestamp.
> 
> This issue was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied.
