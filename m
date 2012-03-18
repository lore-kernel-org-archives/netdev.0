From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 0/9] bnx2x: feature patch series
Date: Sun, 18 Mar 2012 16:33:36 -0400
Message-ID: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1278 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752930Ab2CRNsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2012 09:48:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

This patch series contains several small features, including
a fix of the consistent statistics for boards with old bc firmware
(this feature still exists only in 'net-next', hence why it isn't being
submitted to 'net'), as well as several semantic changes - 
mostly the revision of the bnx2x's prints.

Please consider applying this series to 'net-next'.

Thanks,
Yuval
