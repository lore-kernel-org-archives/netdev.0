From: David Miller <davem@davemloft.net>
Subject: Re: New commands to configure IOV features
Date: Tue, 17 Jul 2012 14:11:53 -0700 (PDT)
Message-ID: <20120717.141153.46613285253481776.davem@davemloft.net>
References: <5003DC9B.8000706@broadcom.com>
	<5005BD00.4090106@redhat.com>
	<5005D45D.1040302@genband.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ddutile@redhat.com, yuvalmin@broadcom.com,
	bhutchings@solarflare.com, gregory.v.rose@intel.com,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: chris.friesen@genband.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <5005D45D.1040302@genband.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Friesen <chris.friesen@genband.com>
Date: Tue, 17 Jul 2012 15:08:45 -0600

> From that perspective a sysfs-based interface is ideal since it is
> directly scriptable.

As is anything ethtool or netlink based, since we have 'ethtool'
and 'ip' for scripting.
