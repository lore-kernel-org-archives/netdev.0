From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 0/2] PCI-Express Non-Transparent Bridge Support
Date: Tue, 20 Nov 2012 15:10:25 -0500 (EST)
Message-ID: <20121120.151025.110295017516927341.davem@davemloft.net>
References: <1353119233-32752-1-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	dave.jiang@intel.com, nab@linux-iscsi.org
To: jon.mason@intel.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1353119233-32752-1-git-send-email-jon.mason@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Mason <jon.mason@intel.com>
Date: Fri, 16 Nov 2012 19:27:11 -0700

> I am submitting version 6 of the PCI-Express Non-Transparent Bridge
> patches for inclusion in 3.8 via Greg KH's char-misc-next tree.  All
> outstanding issues have been addressed.
> 
> Version 6 corrects Greg KH's issues, most notably the improper usage of
> the Linux device model.
> http://thread.gmane.org/gmane.linux.kernel.pci/18599

For the networking bits:

Acked-by: David S. Miller <davem@davemloft.net>
