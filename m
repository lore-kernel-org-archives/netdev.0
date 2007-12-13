From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] ethtool: update license field in specfile to be correctly
	defined
Date: Wed, 12 Dec 2007 16:37:14 -0800
Message-ID: <20071213003714.2743.49355.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44909 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751328AbXLMAih (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 19:38:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RPM uses "License" as field and not "Copyright".

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
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
