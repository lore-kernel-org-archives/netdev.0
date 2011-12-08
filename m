From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 0/6] tg3: Stats and flowctrl cleanups
Date: Thu, 8 Dec 2011 13:49:56 -0800
Message-ID: <1323381002-31565-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2472 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751110Ab1LHVti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 16:49:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset integrates a few flow control and statistics cleanups.
