From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 0/8] tg3: Driver bugfixes
Date: Fri, 4 Nov 2011 12:14:57 -0700
Message-ID: <1320434105-12898-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1763 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755859Ab1KDTOD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 15:14:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset implements a few error path workarounds and corrects a few
problems around tg3_reset_task() scheduling.
