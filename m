From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: davinci_mdio: Set of_node in the mdio bus
Date: Fri, 29 Apr 2016 01:19:31 +0200
Message-ID: <20160428231931.GB17679@lunn.ch>
References: <1461595571-11438-1-git-send-email-Linux.HWI@garmin.com>
 <20160428.154410.1087934312951322476.davem@davemloft.net>
 <57228318.90600@garmin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Grygorii.Strashko@linaro.org,
	jay.schroeder@garmin.com, ben.mccauley@garmin.com
To: "J.D. Schroeder" <Linux.HWI@garmin.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57228318.90600@garmin.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Is there another way to be able to make the of_mdio_find_bus() call be able to
> find the davinci mdio bus?

I missed the first post, and i cannot find it in the archive. Can you
explain what your problem is please.

So long as you call of_mdiobus_register() passing the correct device
node, it should all work.

      Andrew
