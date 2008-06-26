From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb: completely disable interrupts during netpoll
Date: Wed, 25 Jun 2008 17:29:11 -0700 (PDT)
Message-ID: <20080625.172911.189232903.davem@davemloft.net>
References: <36D9DB17C6DE9E40B059440DB8D95F52057B3B27@orsmsx418.amr.corp.intel.com>
	<20080625203519.GU4392@parisc-linux.org>
	<20080625203931.GA32408@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matthew@wil.cx, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: andy@greyhouse.net
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20080625203931.GA32408@gospo.rdu.redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Gospodarek <andy@greyhouse.net>
Date: Wed, 25 Jun 2008 16:39:31 -0400

> Just for the record, most of the other net-drivers do it
> this way too.

Ummm, really?

No NAPI based driver I ever wrote does this.
