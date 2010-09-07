From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net/jme: Use pr_<level>
Date: Mon, 06 Sep 2010 18:30:44 -0700 (PDT)
Message-ID: <20100906.183044.27790719.davem@davemloft.net>
References: <1283674865.23280.42.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cooldavid@cooldavid.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283674865.23280.42.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 05 Sep 2010 01:21:05 -0700

> Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> Convert jeprintk to pr_err
> Remove jeprintk macro define
> Remove periods from end of logging messages
> Coalesce format strings
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
