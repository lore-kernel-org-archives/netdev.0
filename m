From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8169: Add support for restarting
 auto-negotiation
Date: Mon, 05 Dec 2016 13:39:12 -0500 (EST)
Message-ID: <20161205.133912.1382393671449109403.davem@davemloft.net>
References: <20161203200119.1474-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hau@realtek.com, romieu@fr.zoreil.com,
        nic_swsd@realtek.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161203200119.1474-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat,  3 Dec 2016 12:01:19 -0800

> Implement ethtooll::nway_restart by utilizing mii_nway_restart.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
