From: Thomas Gleixner <tglx@linutronix.de>
Subject: Request for stable inclusion
Date: Wed, 30 Apr 2014 21:03:36 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1404302055200.6261@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Ertman <davidx.m.ertman@intel.com>,
	netdev@vger.kernel.org
To: stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

commit b20a774495671f037e7160ea2ce8789af6b61533
Author: David Ertman <davidx.m.ertman@intel.com>
Date:   Tue Mar 25 04:27:55 2014 +0000

    e1000e: Fix no connectivity when driver loaded with cable out

fixes an issue which affects quite some of the newer Laptops and also
Desktops (e.g. AOI-PCs) which are based on mobile chipsets.

I don't know how far this reaches back, but at least the 3.13 and 3.14
kernels need this fix. Jeff, David, can you tell?

Please consider for inclusion.

Thanks,

	tglx
