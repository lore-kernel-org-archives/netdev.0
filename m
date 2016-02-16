From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Tue, 16 Feb 2016 21:57:56 +0100
Message-ID: <20160216205756.GD2558@lunn.ch>
References: <20160212171829.GD13273@lunn.ch>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB12@CHN-SV-EXMX02.mchp-main.com>
 <20160216203625.GC2558@lunn.ch>
 <20160216.154358.164326104187806534.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, f.fainelli@gmail.com, netdev@vger.kernel.org
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47783 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301AbcBPU6A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 15:58:00 -0500
Content-Disposition: inline
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I believe I can make the physical phys accessible through
> ethertool. Would that be reasonable?

How, you have no netdev to attach them to?

There was a nice presentation at netdev last week by Mellanox about
their switches. I don't know if the video is available yet, but that
shows the correct way to do this.

      Andrew
