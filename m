From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] iproute2: sch_rr support in tc
Date: Tue, 14 Aug 2007 11:21:11 -0700
Message-ID: <20070814182111.3800.38619.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:30493 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753486AbXHNSVQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 14:21:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

These patches are resubmissions of patches that were approved, but didn't
get merged.  The first patch is Patrick McHardy's nested compat attribute
patch to the netlink libraries.  The second patch adds multiqueue and sch_rr
functionality to tc.  The multiqueue features have been merged to 2.6.23, so
we'll need these patches to manage the new kernel features.

These patches are unmodified from the version that was approved.  They've been
applied to the latest iproute2 commit.

-- 
PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
