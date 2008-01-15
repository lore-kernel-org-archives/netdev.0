From: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Subject: [PATCH 0/4] bonding: Fix workqueue manipulation and lock taking
Date: Tue, 15 Jan 2008 15:36:04 +0900
Message-ID: <20080115063604.577118000@miraclelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:9815 "EHLO
	dhcp-0021.miraclelinux.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751737AbYAOGeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 01:34:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix some workqueue manipulation and lock taking in bonding driver.

PATCH 1/4 through PATCH 3/4 are on workqueue manipulation, PATCH 4/4 is on lock taking, and each patch are logically independent. Patches are for latest netdev-2.6 git.

-- 
Makito SHIOKAWA
MIRACLE LINUX CORPORATION 
