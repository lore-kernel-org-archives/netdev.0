From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v6 2/4] net: dsa: add new DSA switch driver for the
 SMSC-LAN9303
Date: Thu, 20 Apr 2017 10:41:27 -0700
Message-ID: <40835651-8d27-13eb-e0df-e9438aefb117@gmail.com>
References: <20170418084827.19613-1-jbe@pengutronix.de>
 <20170418084827.19613-3-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@pengutronix.de,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170418084827.19613-3-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/18/2017 01:48 AM, Juergen Borleis wrote:
> The SMSC/Microchip LAN9303 is an ethernet switch device with one CPU port
> and two external ethernet ports with built-in phys.
> 
> This driver uses the DSA framework, but is currently only capable of
> separating the two external ports. There is no offload support yet.
> 
> Signed-off-by: Juergen Borleis <jbe@pengutronix.de>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
