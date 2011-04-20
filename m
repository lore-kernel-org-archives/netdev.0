From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 0/9] tg3: Bugfixes and cleanups
Date: Wed, 20 Apr 2011 10:57:34 -0700
Message-ID: <1303322263-18991-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1814 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752176Ab1DTRs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 13:48:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds a few low-priority bugfixes and adds accessors
for the phy aux ctrl registers.


