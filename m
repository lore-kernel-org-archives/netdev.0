From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 0/7] tg3: Cleanups
Date: Wed, 9 Mar 2011 18:58:18 -0800
Message-ID: <1299725905-8498-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4230 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752327Ab1CJC6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 21:58:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds a 5719 workaround, VPD RODATA checksum verification,
and some code cleanups


