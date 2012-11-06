From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH v5 0/2] PCI-Express Non-Transparent Bridge Support
Date: Mon,  5 Nov 2012 17:11:07 -0700
Message-ID: <1352160669-4330-1-git-send-email-jon.mason@intel.com>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>,
	Greg KH <gregkh@linuxfoundation.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am submitting version 5 of the PCI-Express Non-Transparent Bridge
patches for inclusion in 3.8 via Greg KH's char-misc-next tree.  All
outstanding issues have been addressed.

Version 1
http://thread.gmane.org/gmane.linux.kernel.pci/16443

Version 2 incorporates numerous clean-ups
http://thread.gmane.org/gmane.linux.kernel.pci/16696

Version 3 incorporates changes to conform NTB and client devices to the
Linux device model (per Greg KH's request).
http://thread.gmane.org/gmane.linux.kernel.pci/17808

Version 4 removes the transport transmit tasklet (per Dave Miller's
request)
http://thread.gmane.org/gmane.linux.network/244491

Version 5 corrects a MSI-X bug and cleans up some comments 
http://thread.gmane.org/gmane.linux.kernel.pci/18030

Thanks,
Jon
