From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: calxeda: xgmac: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 05 Dec 2016 15:34:48 -0500 (EST)
Message-ID: <20161205.153448.321319212606395914.davem@davemloft.net>
References: <1480891073-23166-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480891073-23166-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  4 Dec 2016 23:37:53 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
