From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 0/6] tg3: Bugfix and EEE updates
Date: Mon, 6 Dec 2010 10:28:48 -0800
Message-ID: <1291660134-3801-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2565 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754329Ab0LFS3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Dec 2010 13:29:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch integrates a jumbo frame bd flag bugfix and a few EEE refinements.


