From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 0/4] tg3: Fix SPEED_UNKNOWN problems and code
 cleanups
Date: Wed, 22 Feb 2012 14:35:17 -0800
Message-ID: <1329950121-18577-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3333 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013Ab2BVWgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Feb 2012 17:36:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes the recently reported SPEED_UNKNOWN problems and adds a few code cleanups.
