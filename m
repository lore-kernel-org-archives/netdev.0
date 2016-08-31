From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net: dsa: add MDB support
Date: Wed, 31 Aug 2016 17:03:17 +0200
Message-ID: <20160831150317.GG15078@lunn.ch>
References: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com>
 <20160829203246.18811-2-vivien.didelot@savoirfairelinux.com>
 <20160831132534.GA15078@lunn.ch>
 <87vayhvx0m.fsf@ketchup.mtl.sfl>
 <20160831143315.GD15078@lunn.ch>
 <871t157zqg.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <871t157zqg.fsf@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> What should we do if the bridge code consider a multicast group as L3?

Hi Vivien

Just drop the word 'group' from the Documentation. And there appears
to be one comment in the code which should be changed.

   Andrew
