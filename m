From: Ron Mercer <ron.mercer@qlogic.com>
Subject: qlge changes for net-next
Date: Mon, 25 Oct 2010 09:17:50 -0700
Message-ID: <1288023473-31490-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	jitendra.kalsaria@qlogic.com, ying.lok@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:57791 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755326Ab0JYRFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Oct 2010 13:05:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes for next-next:

1) Restore VLAN settings after reset.
2) Add firmware info to ethtool reg dump.
3) Version change.

