From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 0/2]net:external loopback support in ethtool
Date: Mon, 27 Jun 2011 23:40:45 -0700
Message-ID: <1309243247-15950-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:36879 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1756244Ab1F1GtF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 02:49:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,
	Adding external loopback support in ethtool self test. External loopback test
	requires special cable need to be connected, so it can not be part of default test.
	Adding separate flag to specify external loopback test.

-Amit
