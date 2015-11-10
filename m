From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 5/6] net: dsa: mv88e6060: add register defines header file
Date: Tue, 10 Nov 2015 15:53:24 +0100
Message-ID: <20151110145324.GB23891@lunn.ch>
References: <5641F04A.9060303@baylibre.com>
 <20151110142550.GB29568@ketchup.mtl.sfl>
 <56420268.90806@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56420268.90806@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Is something like this OK ?
> /*
>  * drivers/net/dsa/mv88e6060.h - Marvell 88e6060 switch chip support
>  * Copyright (c) 2015 Neil Armstrong
>  *
>  * Based on mv88e6xxx.h
>  * Copyright (c) 2008 Marvell Semiconductor
>  *
>  * This program is free software; you can redistribute it and/or modify
>  * it under the terms of the GNU General Public License as published by
>  * the Free Software Foundation; either version 2 of the License, or
>  * (at your option) any later version.
>  */

Yes, that is good, and i really should add my copyright to mv88e6xxx.h
the next time i edit it.

     Thanks
	Andrew
