From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 0/2] qlge: EEH and Mbox command fixes.
Date: Fri,  6 Nov 2009 09:44:56 -0800
Message-ID: <1257529498-17459-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:26379 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868AbZKFRvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 12:51:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Patch 1 adds a line that I accidentally omitted from the previous patch on 10/26.

Patch 2 changes the EEH PCIe reset type to fundamental as required by
this device.

Regards,
Ron Mercer


