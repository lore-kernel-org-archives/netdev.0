From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cris: fix eth_v10.c build error
Date: Fri, 03 Aug 2012 20:33:41 -0700 (PDT)
Message-ID: <20120803.203341.1528759021241176441.davem@davemloft.net>
References: <1344002771-21072-1-git-send-email-geert@linux-m68k.org>
	<501C6EEF.3030100@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, linux-kernel@vger.kernel.org,
	starvik@axis.com, jesper.nilsson@axis.com,
	linux-cris-kernel@axis.com, netdev@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <501C6EEF.3030100@xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Fri, 03 Aug 2012 17:38:07 -0700

> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> Fix build error on cris (not tested, no toolchain here):
> 
> drivers/net/cris/eth_v10.c: error: too many arguments to function 'e100rxtx_interrupt'
> 
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>

Applied, thanks Randy.
