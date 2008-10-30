From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH] [PCI] move ICHx GbE NVM write-protection from e1000e to PCI quirk
Date: Thu, 30 Oct 2008 11:35:28 -0700
Message-ID: <200810301135.29357.jbarnes@virtuousgeek.org>
References: <20081025011358.9975.77556.stgit@gitlost.lost> <200810300916.01468.jbarnes@virtuousgeek.org> <B27EBC40D200ED48A3F4CC2EBEABAE0B20F36FDE@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <B27EBC40D200ED48A3F4CC2EBEABAE0B20F36FDE@orsmsx501.amr.corp.intel.com>
Content-Disposition: inline
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, October 30, 2008 11:29 am Allan, Bruce W wrote:
> On Thursday, October 30, 2008 9:16 AM Jesse Barnes wrote
>
> >If you think it's likely to apply to future devices as well, I'd say you
> >may
> >as well keep it in the driver.
> >
> >Jesse
>
> Yes, it will likely apply to future devices.  I assume you meant to say
> "may as well keep it in the driver *directory*", correct?

Well I was considering everything under drivers/net/e1000e to be part of the 
driver, but yeah.

-- 
Jesse Barnes, Intel Open Source Technology Center
