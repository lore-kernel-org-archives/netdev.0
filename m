From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix up a few missing hashtable.h
 conflict resolutions
Date: Sat, 13 Aug 2016 14:51:15 -0700 (PDT)
Message-ID: <20160813.145115.1969051160543369900.davem@davemloft.net>
References: <alpine.LNX.2.00.1608121632400.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jikos@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1608121632400.22028@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jikos@kernel.org>
Date: Fri, 12 Aug 2016 16:34:49 +0200 (CEST)

> From: Jiri Kosina <jkosina@suse.cz>
> 
> There are a couple of leftover symbol conflicts caused by hashtable.h 
> being included by netdevice.h; those were not caught as build failure 
> (they're "only" a warning, but in fact real bugs). Fix those up.
> 
> Fixes: e87a8f24c ("net: resolve symbol conflicts with generic hashtable.h")
> Reported-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>

Applied, thanks.
