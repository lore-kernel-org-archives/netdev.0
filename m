From: Jon Mason <jon.mason@intel.com>
Subject: [RFC v4 0/2] PCI-Express Non-Transparent Bridge Support
Date: Thu, 27 Sep 2012 15:42:52 -0700
Message-ID: <1348785774-12607-1-git-send-email-jon.mason@intel.com>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@risingtidesystems.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Version 4 of the patch that adds support for PCI-Express Non-Transparent
Bridges in Linux.  This version removes the transport transmit tasklet
(per Dave Miller's request).

Thanks,
Jon
