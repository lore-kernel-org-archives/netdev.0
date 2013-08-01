From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Remove extern from include/net/ scheduling
 prototypes
Date: Wed, 31 Jul 2013 17:24:37 -0700 (PDT)
Message-ID: <20130731.172437.198780183941616730.davem@davemloft.net>
References: <470a8782ea89cee979eca82c7847748129de6bd0.1375249605.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <470a8782ea89cee979eca82c7847748129de6bd0.1375249605.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 30 Jul 2013 22:47:13 -0700

> There are a mix of function prototypes with and without extern
> in the kernel sources.  Standardize on not using extern for
> function prototypes.
> 
> Function prototypes don't need to be written with extern.
> extern is assumed by the compiler.  Its use is as unnecessary as
> using auto to declare automatic/local variables in a block.
> 
> Reflow modified prototypes to 80 columns.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks.
