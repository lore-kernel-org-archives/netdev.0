From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 0/6] more sky2 patches for 2.6.16.42-rc1
Date: Fri, 23 Feb 2007 15:10:42 -0800
Message-ID: <20070223231042.860031000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40964 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933261AbXBWXRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 18:17:23 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

More backport of sky2 stuff.
	* [bugfix] ram buffer setup
	* [bugfix] listen to pause packets
	* [bugfix] big endian
	
Optional:
	* add more statistics (add entries to table)
	* add more pci-ids for newer boards
	* update version and email address

--
Stephen Hemminger <shemminger@linux-foundation.org>

