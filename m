From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 0/9] tg3: Add 4k workaround for 5719
Date: Wed, 27 Jul 2011 17:20:45 -0700
Message-ID: <1311812454-18197-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4050 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753106Ab1G1AR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2011 20:17:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds a necessary 4k RDMA limit workaround for 5719 devices.


