From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 00/19] Thunderbolt networking
Date: Mon, 02 Oct 2017 11:25:15 -0700 (PDT)
Message-ID: <20171002.112515.1312555425720367220.davem@davemloft.net>
References: <20171002103846.64602-1-mika.westerberg@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, andreas.noever@gmail.com,
        michael.jamet@intel.com, yehezkel.bernat@intel.com,
        amir.jer.levy@intel.com, Mario.Limonciello@dell.com,
        lukas@wunner.de, andriy.shevchenko@linux.intel.com, andrew@lunn.ch,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mika.westerberg@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171002103846.64602-1-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mika Westerberg <mika.westerberg@linux.intel.com>
Date: Mon,  2 Oct 2017 13:38:27 +0300

> In addition of tunneling PCIe, Display Port and USB traffic, Thunderbolt
> allows connecting two hosts (domains) over a Thunderbolt cable. It is
> possible to tunnel arbitrary data packets over such connection using
> high-speed DMA rings available in the Thunderbolt host controller.

Series applied to net-next, thanks!
