From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 0/12] bnx2x: ethtool and other enhancements
Date: Wed, 13 Jun 2012 15:44:12 +0300
Message-ID: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2749 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752387Ab2FMJmd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 05:42:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series adds few features to bnx2x:
Add support for external LB in ethtool self-test
Enable UDP RSS on 4-tupple, controlled by ethtool
Support up to 63 RSS queues (rather than 16)
Add support for setting the desired number of RSS queues via ethtool
Allow to configure dcbx admin params from all drivers on a single physical port
Add FCoE capabilities advertisement

Please consider applying this patch series to net-next.

Thanks,
Merav
