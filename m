From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net v2 0/2] xen-net{front,back}: respect user provided max_queues
Date: Wed, 9 Sep 2015 11:23:04 +0100
Message-ID: <1441794186-26991-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>
To: Xen-devel <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:18758 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755103AbbIIKXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 06:23:08 -0400
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
