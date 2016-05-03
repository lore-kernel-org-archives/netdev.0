From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: ethernet: gianfar: move to new ethtool api
 {get|set}_link_ksettings
Date: Tue, 03 May 2016 13:04:03 -0400 (EDT)
Message-ID: <20160503.130403.171567496840433345.davem@davemloft.net>
References: <1462115291-11372-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	claudiu.manoil@freescale.com, leoli@freescale.com,
	treding@nvidia.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462115291-11372-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  1 May 2016 17:08:08 +0200

> The ethtool api {get|set}_settings is deprecated.
> We move the gianfar driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
