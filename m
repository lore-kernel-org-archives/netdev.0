From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool] ethtool: Add ntuple to the -K option in the man page.
Date: Thu, 19 Jan 2012 22:13:51 -0800
Message-ID: <1327040031-19152-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Amir Hanania <amir.hanania@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:48657 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353Ab2ATGNz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jan 2012 01:13:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Hanania <amir.hanania@intel.com>

Signed-off-by: Amir Hanania <amir.hanania@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ethtool.8.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index e6e46cc..9b8c5bc 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -212,6 +212,7 @@ ethtool \- query or control network driver and hardware settings
 .B2 gso on off
 .B2 gro on off
 .B2 lro on off
+.B2 ntuple on off
 .B2 rxvlan on off
 .B2 txvlan on off
 .B2 rxhash on off
-- 
1.7.7.5
