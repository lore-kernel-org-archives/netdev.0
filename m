From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: cavium: octeon: use
 phy_ethtool_{get|set}_link_ksettings
Date: Mon, 04 Jul 2016 16:01:12 -0700 (PDT)
Message-ID: <20160704.160112.315016050181513400.davem@davemloft.net>
References: <1467495420-23359-1-git-send-email-tremyfr@gmail.com>
	<1467495420-23359-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, ivecera@redhat.com, a@unstable.cc,
	fw@strlen.de, david.daney@cavium.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467495420-23359-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat,  2 Jul 2016 23:37:00 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
