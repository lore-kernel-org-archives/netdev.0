From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 0/2] xen-netback: windows frontend compatibility fixes
Date: Fri, 20 Sep 2013 14:57:38 +0100
Message-ID: <1379685460-25032-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:11246 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042Ab3ITN5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 09:57:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches fix a couple more issues found when testing with
Windows frontends.

v2:
- Add comment in 2/2 to note that state transitions from Connected to Closed
  are incorrect.
