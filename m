From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH 0/2] PCI-Express Non-Transparent Bridge Support
Date: Tue,  2 Oct 2012 14:26:15 -0700
Message-ID: <1349213177-9985-1-git-send-email-jon.mason@intel.com>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@risingtidesystems.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am submitting version 4 of the PCI-Express Non-Transparent Bridge
patches for inclusion in 3.7.  All outstanding issues from the RFC
process have been addressed.

version 1
http://thread.gmane.org/gmane.linux.kernel.pci/16443

Version 2 incorporates numerous clean-ups 
http://thread.gmane.org/gmane.linux.kernel.pci/16696

Version 3 incorporates changes to conform NTB and client devices to the
Linux device model (per Greg KH's request).
http://thread.gmane.org/gmane.linux.kernel.pci/17808

Version 4 removes the transport transmit tasklet (per Dave Miller's
request).
http://thread.gmane.org/gmane.linux.network/244491

Thanks,
Jon
