From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/7] pci: Add VPD parsing support
Date: Sat, 27 Feb 2010 03:08:31 -0800 (PST)
Message-ID: <20100227.030831.210644479.davem@davemloft.net>
References: <1267229085-21303-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbarnes@virtuousgeek.org, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1267229085-21303-1-git-send-email-mcarlson@broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 26 Feb 2010 16:04:38 -0800

> This patch adds code to help parse a device's VPD.  The bnx2 and tg3
> network drivers are modified as an example on how to use the API.  I
> believe the bnx2x driver will also use this API in the future.

PCI folks, ok with this?

And if so, OK if I merge this via the net-next-2.6 tree?

Thanks!
