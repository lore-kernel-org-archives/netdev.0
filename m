From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: add EEPROM support to
 6390
Date: Fri, 13 Jan 2017 20:18:10 -0500 (EST)
Message-ID: <20170113.201810.1158668449050217504.davem@davemloft.net>
References: <20170112230716.2083-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
        cphealy@gmail.com, nikita.yoush@cogentembedded.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170112230716.2083-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu, 12 Jan 2017 18:07:16 -0500

> The Marvell 6352 chip has a 8-bit address/16-bit data EEPROM access.
> The Marvell 6390 chip has a 16-bit address/8-bit data EEPROM access.
> 
> This patch implements the 8-bit data EEPROM access in the mv88e6xxx
> driver and adds its support to chips of the 6390 family.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
