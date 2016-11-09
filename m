From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: amd: pcnet32: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 09 Nov 2016 13:25:43 -0500 (EST)
Message-ID: <20161109.132543.774039292025483725.davem@davemloft.net>
References: <1478388401-13029-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pcnet32@frontier.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478388401-13029-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  6 Nov 2016 00:26:41 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
