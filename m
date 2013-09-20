From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 0/2] xen-netback: windows frontend compatibility fixes
Date: Fri, 20 Sep 2013 13:56:29 +0100
Message-ID: <1379681791-21842-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:60140 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634Ab3ITM4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 08:56:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches fix a couple more issues found when testing with Windows
frontends.
