From: Valerie Henson <val_henson@linux.intel.com>
Subject: [patch 00/10] [TULIP] Tulip update
Date: Fri, 08 Sep 2006 11:15:33 -0700
Message-ID: <20060908181533.771856000@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:64339 "EHLO mga09.intel.com")
	by vger.kernel.org with ESMTP id S1751046AbWIHSUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2006 14:20:31 -0400
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Resend with bugs fixed.]

This patch set includes all the non-controversial tulip patches from
the parisc tree, plus a few extra cleanups.  The major highlight is
the patch moving tulip_select_media() and its associated delay to a
work queue, a nice piece of work from Francois Romieu, with some
tweaks by Kyle McMartin.

-VAL
