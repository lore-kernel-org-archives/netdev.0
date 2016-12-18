From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: chelsio: cxgb2: use new api
 ethtool_{get|set}_link_ksettings
Date: Sat, 17 Dec 2016 21:31:52 -0500 (EST)
Message-ID: <20161217.213152.2289251785085392648.davem@davemloft.net>
References: <1481492870-12222-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481492870-12222-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 11 Dec 2016 22:47:50 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
