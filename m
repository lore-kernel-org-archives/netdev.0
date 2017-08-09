From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Use tab for indentation in Kconfig
Date: Tue, 08 Aug 2017 21:05:37 -0700 (PDT)
Message-ID: <20170808.210537.1599851067118765908.davem@davemloft.net>
References: <abacdc7ec0585cfbeba240ca2780c6020cf7090a.1502184742.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, monstr@monstr.eu,
        netdev@vger.kernel.org, andrew@lunn.ch, f.fainelli@gmail.com
To: michal.simek@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <abacdc7ec0585cfbeba240ca2780c6020cf7090a.1502184742.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Simek <michal.simek@xilinx.com>
Date: Tue,  8 Aug 2017 11:32:25 +0200

> Using tabs instead of space for indentaion
> 
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>

This really isn't appropriate for the 'net' tree, it doesn't fix
anything it just makes the spacing consistent.

Please respin this patch against net-next, thank you.
