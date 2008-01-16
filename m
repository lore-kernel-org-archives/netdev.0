From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH] ethtool: update license field in specfile to be correctly defined
Date: Tue, 15 Jan 2008 18:33:44 -0800
Message-ID: <20080116023344.6422.58799.stgit@jbrandeb-bw.jf.intel.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:50443 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754293AbYAPCdM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 21:33:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The ethtool spec file needs to have the correct syntax license line.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 ethtool.spec.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ethtool.spec.in b/ethtool.spec.in
index 1705d7f..4ff736a 100644
--- a/ethtool.spec.in
+++ b/ethtool.spec.in
@@ -5,7 +5,7 @@ Group		: Utilities
 
 Summary		: A tool for setting ethernet parameters
 
-Copyright	: GPL
+License		: GPL
 URL		: http://sourceforge.net/projects/gkernel/
 
 Buildroot	: %{_tmppath}/%{name}-%{version}
