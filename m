From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net v3 0/2] xen-net{front,back}: respect user provided max_queues
Date: Thu, 10 Sep 2015 11:18:56 +0100
Message-ID: <1441880338-4911-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>
To: Xen-devel <xen-devel@lists.xenproject.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:35993 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbbIJKTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 06:19:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei Liu (2):
  xen-netback: respect user provided max_queues
  xen-netfront: respect user provided max_queues

 drivers/net/xen-netback/netback.c | 7 +++++--
 drivers/net/xen-netfront.c        | 7 +++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

-- 
2.1.4
