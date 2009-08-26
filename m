From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] drivers/net/s2io.c: Cleanups
Date: Wed, 26 Aug 2009 15:33:53 -0700 (PDT)
Message-ID: <20090826.153353.259743590.davem@davemloft.net>
References: <cover.1251170438.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, anil.murthy@neterion.com,
	sreenivasa.honnur@neterion.com, sivakumar.subramani@neterion.com,
	santosh.rastapur@neterion.com, ram.vepa@neterion.com,
	akpm@linux-foundation.org, linux-next@vger.kernel.org
To: joe@perches.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <cover.1251170438.git.joe@perches.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 24 Aug 2009 20:29:39 -0700

> Just a few cleanups, compiled, untested.  No hardware.
> 
> Joe Perches (9):
>   s2io.c: Use const for strings
>   s2io.c: Shorten code line length by using intermediate pointers
>   s2io.c: Use calculated size in kmallocs
>   s2io.c: use kzalloc
>   s2io.c: Make more conforming to normal kernel style
>   s2io.c: convert printks to pr_<level>
>   s2io.c: fix spelling explaination
>   s2io.c: Standardize statistics accessors
>   s2io.c: Convert skipped nic->config.tx_cfg[i]. to tx_cfg->

Since this is a pretty serious set of cleanups, I'd like to
let the S2IO driver folks have some time to look at this and
at least have a chance to ACK/NACK them.
