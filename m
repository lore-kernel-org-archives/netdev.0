From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] net: ethernet: fec_mpc52xx: move to new ethtool
 api {get|set}_link_ksettings
Date: Tue, 03 May 2016 13:04:20 -0400 (EDT)
Message-ID: <20160503.130420.603797791097846992.davem@davemloft.net>
References: <1462115291-11372-1-git-send-email-tremyfr@gmail.com>
	<1462115291-11372-4-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	claudiu.manoil@freescale.com, leoli@freescale.com,
	treding@nvidia.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462115291-11372-4-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  1 May 2016 17:08:11 +0200

> The ethtool api {get|set}_settings is deprecated.
> We move the fec_mpc52xx driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
