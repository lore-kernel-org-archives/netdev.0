From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH v3 0/7] pci: Add VPD parsing support
Date: Sat, 27 Feb 2010 08:46:30 -0800
Message-ID: <20100227084630.6d556003@jbarnes-piketon>
References: <1267229085-21303-1-git-send-email-mcarlson@broadcom.com>
	<20100227.030831.210644479.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20100227.030831.210644479.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 27 Feb 2010 03:08:31 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Fri, 26 Feb 2010 16:04:38 -0800
> 
> > This patch adds code to help parse a device's VPD.  The bnx2 and tg3
> > network drivers are modified as an example on how to use the API.  I
> > believe the bnx2x driver will also use this API in the future.
> 
> PCI folks, ok with this?
> 
> And if so, OK if I merge this via the net-next-2.6 tree?

Yeah, latest round looks good to me.  Thanks for doing this, Matt!

Acked-by: Jesse Barnes <jbarnes@virtuousgeek.org>

-- 
Jesse Barnes, Intel Open Source Technology Center
