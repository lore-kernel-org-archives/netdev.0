From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 0/4] tg3: Cleanups, corrections, and MDI-X
Date: Mon, 21 Nov 2011 17:01:16 -0800
Message-ID: <1321923680-7925-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4504 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757628Ab1KVBCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Nov 2011 20:02:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset cleans-up 1000Base-X flow control resolution, then continues
on to tune some thresholds and then adds MDI-X reporting.
