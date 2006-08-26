From: Valerie Henson <val_henson@linux.intel.com>
Subject: [patch 00/10] [TULIP] Tulip update
Date: Fri, 25 Aug 2006 17:02:27 -0700
Message-ID: <20060826000227.818796000@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:59488 "EHLO
	orsmga101.jf.intel.com") by vger.kernel.org with ESMTP
	id S1422927AbWHZADE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 20:03:04 -0400
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set includes all the non-controversial tulip patches from
the parisc tree, plus a few extra cleanups.  The major highlight is
the patch moving tulip_select_media() and its associated delay to a
work queue, a nice piece of work from Francois Romieu, with some
tweaks by Kyle McMartin.

-VAL
