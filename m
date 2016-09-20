From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: broadcom: b44: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 19 Sep 2016 21:40:12 -0400 (EDT)
Message-ID: <20160919.214012.243221480746726402.davem@davemloft.net>
References: <1474150295-24622-1-git-send-email-tremyfr@gmail.com>
        <1474150295-24622-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474150295-24622-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 18 Sep 2016 00:11:35 +0200

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
