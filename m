From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NET-2.6 0/1]qlcnic: bug fix
Date: Tue, 12 Apr 2011 00:19:40 -0700
Message-ID: <1302592781-13881-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:59042 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754712Ab1DLHTt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 03:19:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,
	Apply this fix to net-2.6 tree.
	This patch will give hunk failure while merging to net-next tree.
	Somehow I can't avoid it. Two lines below diff has changed in qlcnic_xmit_frame().

-Amit
