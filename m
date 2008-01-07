From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/3] ethtool: update license field in specfile to be correctly
	defined
Date: Mon, 07 Jan 2008 09:36:11 -0800
Message-ID: <20080107173611.8429.28898.stgit@localhost.localdomain>
References: <20080107173602.8429.56354.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	davem@davemloft.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10115 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754756AbYAGRgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 12:36:17 -0500
In-Reply-To: <20080107173602.8429.56354.stgit@localhost.localdomain>
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

