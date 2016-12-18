From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: chelsio: cxgb3: use new api
 ethtool_{get|set}_link_ksettings
Date: Sat, 17 Dec 2016 21:31:58 -0500 (EST)
Message-ID: <20161217.213158.229747834705447706.davem@davemloft.net>
References: <1481498870-16946-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh@chelsio.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481498870-16946-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Mon, 12 Dec 2016 00:27:49 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
