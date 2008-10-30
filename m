From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [PATCH] [PCI] move ICHx GbE NVM write-protection from e1000e to
 PCI quirk
Date: Thu, 30 Oct 2008 11:29:15 -0700
Message-ID: <B27EBC40D200ED48A3F4CC2EBEABAE0B20F36FDE@orsmsx501.amr.corp.intel.com>
References: <20081025011358.9975.77556.stgit@gitlost.lost>
 <490282FE.9040602@garzik.org>
 <B27EBC40D200ED48A3F4CC2EBEABAE0B20B38046@orsmsx501.amr.corp.intel.com>
 <200810300916.01468.jbarnes@virtuousgeek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jeff Garzik <jeff@garzik.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <200810300916.01468.jbarnes@virtuousgeek.org>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, October 30, 2008 9:16 AM Jesse Barnes wrote
>
>If you think it's likely to apply to future devices as well, I'd say you
>may
>as well keep it in the driver.
>
>Jesse
>

Yes, it will likely apply to future devices.  I assume you meant to say "may as well keep it in the driver *directory*", correct?

Thanks,
Bruce.
