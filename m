From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 0/6] tg3: 57766 support and new features
Date: Wed, 14 Dec 2011 13:09:56 -0800
Message-ID: <1323897002-17295-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4933 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758142Ab1LNVJm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Dec 2011 16:09:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds 57766 ASIC rev support, adds admin control over
the RSS indirection table and makes a few minor cleanups.
