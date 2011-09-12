From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next-2.6] can/sja1000: driver for PEAK PCAN PCI/PCIe
 cards
Date: Mon, 12 Sep 2011 17:49:53 +0200
Message-ID: <4E6E2A21.7010701@hartkopp.net>
References: <4E692080.9020801@grandegger.com> <4E6A25EE.3000501@hartkopp.net> <4E6A2EB2.5070601@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev@vger.kernel.org,
	SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>,
	linux@peak-system.com, Thomas Wiedemann <Thomas.Wiedemann@iav.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4E6A2EB2.5070601@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/11 17:20, Wolfgang Grandegger wrote:


> 
>> I'll also test your driver on Monday.
> 
> Thanks,


Hi Wolfgang,

even if i only had my hardware-patched PEAK PCI ExpressCard hardware here
(which is to be removed in the supported PCI device list due to the missing
I2C initialization), i successfully tested your driver.

Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>

So let's wait for some feedback from Thomas, when he's back to the office ;-)

Tnx & best regards,
Oliver
