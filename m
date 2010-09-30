From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 0/8] tg3: Bugfixes and updates
Date: Thu, 30 Sep 2010 13:34:29 -0700
Message-ID: <1285878877-12148-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2215 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756591Ab0I3Uey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 16:34:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset implements some bugfixes, removes the 5724 device
ID and introduces extended rx buffer rings.


