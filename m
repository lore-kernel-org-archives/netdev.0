From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cirrus: cs89x0: Use managed interfaces
Date: Sat, 02 Aug 2014 16:41:04 -0700 (PDT)
Message-ID: <20140802.164104.2280645832684968269.davem@davemloft.net>
References: <20140801152819.GA11441@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140801152819.GA11441@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Fri, 1 Aug 2014 20:58:19 +0530

> This patch introduces the use of managed interfaces like
> devm_ioremap_resource and does away with the functions to free the
> allocated memory in the probe and remove functions. Also, many labels
> are done away with. The field size in no longer needed and is hence
> removed from the struct net_local.
> 
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied.
