From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: Drop WARN() in tag_brcm.c
Date: Tue, 24 Jan 2017 15:00:40 -0500 (EST)
Message-ID: <20170124.150040.1773076921308385136.davem@davemloft.net>
References: <20170124031907.28328-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170124031907.28328-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 23 Jan 2017 19:19:07 -0800

> We may be able to see invalid Broadcom tags when the hardware and drivers are
> misconfigured, or just while exercising the error path. Instead of flooding
> the console with messages, flat out drop the packet.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
