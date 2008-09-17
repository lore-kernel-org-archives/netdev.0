From: "Benjamin Li" <benli@broadcom.com>
Subject: [NET-NEXT PATCH] Minor bnx2 patches
Date: Wed, 17 Sep 2008 16:02:17 -0700
Message-ID: <cover.1219454143.git.benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1621 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753466AbYIQXCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Sep 2008 19:02:31 -0400
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.11.18.52]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id 0A8E92B0 for
 <netdev@vger.kernel.org>; Wed, 17 Sep 2008 16:02:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches are some minor code cleanups.  Nothing
major.

Please feel free to comment.  Thanks again.

-Ben

Benjamin Li (4):
  bnx2: In bnx2_set_mac_link() return void rather then int
  bnx2: Update MODULE_DESCRIPTION to include the 5716
  bnx2: Remove name field from bnx2 structure
  bnx2: Remove timer_interval field from the bnx2 structure

 drivers/net/bnx2.c |   20 ++++++++------------
 drivers/net/bnx2.h |    4 +---
 2 files changed, 9 insertions(+), 15 deletions(-)


