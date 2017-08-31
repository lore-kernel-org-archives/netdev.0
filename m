From: David Miller <davem@davemloft.net>
Subject: Re: DSA mv88e6xxx RX frame errors and TCP/IP RX failure
Date: Thu, 31 Aug 2017 10:44:35 -0700 (PDT)
Message-ID: <20170831.104435.1288286218065675397.davem@davemloft.net>
References: <20170831014624.GA18554@lunn.ch>
        <CAJ+vNU0dq-ULUj3PbQH_biGviJURj2z5McCXx_vYxcB0k94WkA@mail.gmail.com>
        <20170831174141.GP22289@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tharvey@gateworks.com, netdev@vger.kernel.org,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org,
        fugang.duan@nxp.com, imirkin@alum.mit.edu
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170831174141.GP22289@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu, 31 Aug 2017 19:41:41 +0200

> Please could you add
> 
> fbbeefdd2104 ("net: fec: Allow reception of frames bigger than 1522 bytes")
> 
> to stable.

Queued up, thanks.
