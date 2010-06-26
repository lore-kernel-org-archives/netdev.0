From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/core/pktgen.c: Use pr_<level>
Date: Fri, 25 Jun 2010 21:35:33 -0700 (PDT)
Message-ID: <20100625.213533.124076851.davem@davemloft.net>
References: <1277159354.1775.212.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1277159354.1775.212.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 21 Jun 2010 15:29:14 -0700

> Add pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> Remove "pktgen: " from formats
> Convert printks to pr_<level>
> Added func_enter() for debugging
> Moved version to end of string at module_init
> Coalesced long formats
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
