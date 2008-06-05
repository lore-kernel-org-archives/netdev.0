From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 0/3] NET: Add support for VLAN feature flag propagation
Date: Thu, 05 Jun 2008 04:03:29 -0700
Message-ID: <20080605105954.28781.95876.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57725 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884AbYFELEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 07:04:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds the new VLAN feature flag support for TSO and CSUM offload.  It uses the new interface implemented by Patrick McHardy, and can be tested against the latest torvalds/linux-2.6 tree.

-- 
Cheers,
Jeff Kirsher
