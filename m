From: amit.salecha@qlogic.com
Subject: [NET-2.6 PATCHv2 0/1]qlcnic: bug fix
Date: Tue, 12 Apr 2011 20:05:54 -0700
Message-ID: <1302663955-31849-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:60031 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1752181Ab1DMDLK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 23:11:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,
	Apply this fix to net-2.6. this is series two as earlier email got corrupted.
	Same netxen_nic apply to qlcnic.

	This patch will give hunk failure while merging to net-next tree.
	Two lines below diff has changed in qlcnic_xmit_frame().

	Sorry, for all spam and corrupted emails. I understand your work load and
	this nuisance really distrubed all people. As people give their precious time
	in reviewing patches.

	Going forward will make sure these type of events not repeated by Qlogic.

-Amit
