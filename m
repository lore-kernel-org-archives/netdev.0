From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net 0/2] xen-netback: fix debugfs code
Date: Tue, 12 Aug 2014 11:59:28 +0100
Message-ID: <1407841170-20916-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:31541 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752152AbaHLK7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 06:59:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This small series fixes two problems in xen-netback debugfs code.

Wei.

Wei Liu (2):
  xen-netback: fix debugfs write length check
  xen-netback: fix debugfs entry creation

 drivers/net/xen-netback/xenbus.c |   17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

-- 
1.7.10.4
