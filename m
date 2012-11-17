From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH v6 0/2] PCI-Express Non-Transparent Bridge Support
Date: Fri, 16 Nov 2012 19:27:11 -0700
Message-ID: <1353119233-32752-1-git-send-email-jon.mason@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am submitting version 6 of the PCI-Express Non-Transparent Bridge
patches for inclusion in 3.8 via Greg KH's char-misc-next tree.  All
outstanding issues have been addressed.

Version 6 corrects Greg KH's issues, most notably the improper usage of
the Linux device model.
http://thread.gmane.org/gmane.linux.kernel.pci/18599

Thanks,
Jon
