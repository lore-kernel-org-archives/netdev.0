From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 00/11] ixgb: driver update (upstream)
Date: Fri, 21 Apr 2006 18:00:16 -0700
Message-ID: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Cc: John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:46977 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750805AbWDVA5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 20:57:24 -0400
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches were diff's against Garzik's latest "upstream" branch and can be pulled from the following location:

git://lost.foo-projects.org/linux-2.6.git ixgb-upstream


The following series implements...
01. Fix compilation errors by initializing variables
02. Fix the use of dprintk rather than printk
03. Fix hard coded numbers
04. Fix duplicate code
05. Fix timeout code
06. Fix TSO
07. Fixed flow control parameters
08. Add support for copper 10GbE
09. Add performance enhancements to the buffer_info struct
10. Add whitespace changes
11. Add prefetch
--
Cheers,
Jeff

