From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones (was
 Ethernet Bridging: Enable Hardware Checksumming)
Date: Thu, 19 May 2005 14:20:19 -0700
Message-ID: <20050519142019.5963f1c9@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
In-Reply-To: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Also NETIF_F_LLTX should always be set on the bridge, independent of what devices are in it.
