From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Sun, 18 Sep 2011 21:03:08 -0400 (EDT)
Message-ID: <20110918.210308.1560061605041519707.davem@davemloft.net>
References: <20110918194818.GB1641@x4.trippels.de>
	<CA+55aFwmwYXzC_4q+XuEAx3ta6U-jf=NvMcAc-J+4DBxLm8Efg@mail.gmail.com>
	<1316378130.31335.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, markus@trippelsdorf.de,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1316378130.31335.32.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 18 Sep 2011 22:35:30 +0200

> [PATCH] tcp: fix build error if !CONFIG_SYN_COOKIE
> 
> commit 946cedccbd7387 (tcp: Change possible SYN flooding messages)
> added a build error if CONFIG_SYN_COOKIE=n
> 
> Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
