From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXTv3 0/3]qlcnic: enhancement and fixes
Date: Tue, 17 Aug 2010 03:34:18 -0700
Message-ID: <1282041265-32591-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:40535 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757347Ab0HQKe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 06:34:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I have fixed link status message by using netdev_info().

After updating net-next, same patches applied cleanly. Last commit I see
on qlcnic driver is "e88db3bd46801a9c2cd0ac5e46122d47c285faec".

Sending series of v3 patches, apply it on net-next.

-Amit
