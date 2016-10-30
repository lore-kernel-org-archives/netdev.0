From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bonding: use new api
 ethtool_{get|set}_link_ksettings
Date: Sun, 30 Oct 2016 17:23:53 -0400 (EDT)
Message-ID: <20161030.172353.905783228299671520.davem@davemloft.net>
References: <1477413691-10894-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477413691-10894-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Tue, 25 Oct 2016 18:41:31 +0200

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied, thanks.
