From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 0/11] tg3: 5719, VLAN, and EEE bugfixes
Date: Tue, 25 Jan 2011 17:58:46 -0800
Message-ID: <1296007137-23146-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2897 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752337Ab1AZB7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 20:59:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset implements bugfixes for the 5719, the VLAN code and
enhances EEE support.


