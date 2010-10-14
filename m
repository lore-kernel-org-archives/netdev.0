From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 0/8] tg3: Updates and EEE support
Date: Thu, 14 Oct 2010 13:37:37 -0700
Message-ID: <1287088665-22135-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2369 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755919Ab0JNUh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 16:37:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset integrates a few minor changes and adds EEE support
for the 5717 and 57765 asic revs.


