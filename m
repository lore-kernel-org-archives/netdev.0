From: Jason McMullan <jason.mcmullan@timesys.com>
Subject: Re: [PATCH] MII bus API for PHY devices
Date: Tue, 23 Nov 2004 13:18:01 -0500
Message-ID: <1101233881.16246.2.camel@jmcmullan>
References: <069B6F33-341C-11D9-9652-000393DBC2E8@freescale.com>
	 <9B0D9272-398A-11D9-96F6-000393C30512@freescale.com>
	 <1100820391.25521.14.camel@gaston>
	 <97DA0EF0-3A70-11D9-B023-000393C30512@freescale.com>
	 <1100904184.3856.46.camel@gaston>
	 <B2AF8092-3A87-11D9-B023-000393C30512@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <B2AF8092-3A87-11D9-B023-000393C30512@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've added pluggable PHY support modules and a bitbanger MII bus
framework. 

New patch at:
	http://www.evillabs.net/~gus/patches/driver-mii-bus.patch

RPX/EP8260 MII bus example for bit-banger:
	http://www.evillabs.net/~gus/patches/rpx8260_mii.c

-- 
Jason McMullan <jason.mcmullan@timesys.com>
