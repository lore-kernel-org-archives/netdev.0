From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: broadcom: bcmgenet: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 19 Sep 2016 21:40:30 -0400 (EDT)
Message-ID: <20160919.214030.1887991401671338339.davem@davemloft.net>
References: <1474211805-5703-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474211805-5703-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 18 Sep 2016 17:16:45 +0200

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
