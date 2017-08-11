From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] Add LAN743X driver
Date: Sat, 12 Aug 2017 00:34:45 +0200
Message-ID: <20170811223445.GC4671@lunn.ch>
References: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
 <20170811.151205.2131155817966352627.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bryan.Whitehead@microchip.com, netdev@vger.kernel.org,
        UNGLinuxDriver@microchip.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34056 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753742AbdHKWer (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 18:34:47 -0400
Content-Disposition: inline
In-Reply-To: <20170811.151205.2131155817966352627.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This thing is huge, I'm not reviewing any more of this enormous submission.

Yes.

Could you split it up a bit. Take the PTP support out for the moment,
and submit it later once the core driver is accepted. The same for any
other optional bits.

    Andrew
