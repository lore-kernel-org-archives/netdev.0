From: David Miller <davem@davemloft.net>
Subject: Re: nf_tables*.h: Remove extern from function prototypes
Date: Mon, 21 Oct 2013 17:19:21 -0400 (EDT)
Message-ID: <20131021.171921.650196864241149083.davem@davemloft.net>
References: <cover.1382129045.git.joe@perches.com>
	<1382245531.2041.37.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382245531.2041.37.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sat, 19 Oct 2013 22:05:31 -0700

> There are a mix of function prototypes with and without extern
> in the kernel sources.  Standardize on not using extern for
> function prototypes.
> 
> Function prototypes don't need to be written with extern.
> extern is assumed by the compiler.  Its use is as unnecessary as
> using auto to declare automatic/local variables in a block.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

I'll apply this directly, thanks Joe.
