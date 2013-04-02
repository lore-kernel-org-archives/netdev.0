From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 0/4] qlcnic: Bug Fixes
Date: Tue,  2 Apr 2013 11:34:39 -0400
Message-ID: <1364916883-10109-1-git-send-email-rajesh.borundia@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:42314 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1761364Ab3DBP5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 11:57:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply it to net-next.

Rajesh Borundia (4):
  qlcnic: Fix potential NULL dereference
  qlcnic: Fix NULL dereference in error path.
  qlcnic: Fix sparse warnings.
  qlcnic: Bump up the version to 5.2.40
