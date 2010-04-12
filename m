From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 0/8] tg3 updates
Date: Mon, 12 Apr 2010 09:58:23 -0700
Message-ID: <1271091511-11173-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1844 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753198Ab0DLQ66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 12:58:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds code to support the 57765 OTP ROM bootcode, fixes
bug related to VLANs and adds some minor improvements.


