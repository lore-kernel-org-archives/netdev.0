From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch] (0/8) Adding 802.3ad support to bonding
Date: Thu, 20 Mar 2003 11:56:18 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030320165618.GB8256@gtf.org>
References: <Pine.LNX.4.44.0303201553540.10351-100000@jrslxjul4.npdj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bonding Developement list <bonding-devel@lists.sourceforge.net>,
   Bonding Announce list <bonding-announce@lists.sourceforge.net>,
   Linux Net Mailing list <linux-net@vger.kernel.org>,
   Linux Kernel Mailing list <linux-kernel@vger.kernel.org>,
   Oss SGI Netdev list <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Shmulik Hen <hshmulik@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0303201553540.10351-100000@jrslxjul4.npdj.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I (and many others) will be going over these patches.  I also see that
somebody (davem?) applied your divide-by-zero patch to the mainline
kernel.

My initial comment is that we will want to work to eliminate these
ifdefs.  Other comments will follow.

Thanks to Intel for these efforts!

	Jeff
