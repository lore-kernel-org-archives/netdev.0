From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 0/2] Minor ethtool cleanups
Date: Fri, 08 Apr 2011 15:12:28 -0700
Message-ID: <20110408221135.26893.50092.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37926 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757630Ab1DHWMb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 18:12:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes address a few minor issues I noticed in ethtool.

---

Alexander Duyck (2):
      Add support for ESP as a separate protocol from AH
      ethtool: fix manpage so that it will display tables again


 ethtool.8.in |   18 ++++++++++--------
 ethtool.c    |   21 ++++++++++++++++-----
 2 files changed, 26 insertions(+), 13 deletions(-)

-- 
