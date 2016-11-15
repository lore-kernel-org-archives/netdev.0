From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bnx2: use new api ethtool_{get|set}_link_ksettings
Date: Tue, 15 Nov 2016 17:05:46 -0500 (EST)
Message-ID: <20161115.170546.1496815974820728807.davem@davemloft.net>
References: <1479076426-9024-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rasesh.mody@cavium.com, harish.patil@cavium.com,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479076426-9024-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 13 Nov 2016 23:33:46 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
