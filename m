From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ibm: ehea: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 09 Jan 2017 12:10:35 -0500 (EST)
Message-ID: <20170109.121035.171221623267220868.davem@davemloft.net>
References: <1483807667-18264-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dougmill@linux.vnet.ibm.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483807667-18264-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat,  7 Jan 2017 17:47:47 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
