From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 0/6] qlge: fixes for qlge.
Date: Mon,  5 Jul 2010 15:19:36 -0700
Message-ID: <1278368382-23887-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:42713 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752754Ab0GEXFR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 19:05:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Restore promiscuous setting after reset.
2) Don't use firmware when forcing firmware dump.
3) Reduce print level in data path statements.
4) Fix possible endian issue for rx UDP csum.
5) Make adapter drop frame errors and pass up csum errors.
6) Change version to v1.00.00.25.00.00-01.

