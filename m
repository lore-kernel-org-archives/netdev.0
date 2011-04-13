From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 0/5] tg3: Add more selftest and debug support
Date: Wed, 13 Apr 2011 14:05:03 -0700
Message-ID: <1302728708-1797-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1623 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932796Ab1DMU4f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 16:56:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds register dump capabilities for first failure debugging,
a jumbo frame loopback test mode, and extended VPD block handling.


