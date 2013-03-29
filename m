From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 0/7] SR-IOV support for QLogic 83xx series
Date: Fri, 29 Mar 2013 11:46:32 -0400
Message-ID: <1364571999-31593-1-git-send-email-rajesh.borundia@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:29324 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753965Ab3C2QJi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Mar 2013 12:09:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch series to add SR-IOV support in qlcnic driver for 83xx series adapters.
Please apply it to net-next.

Rajesh Borundia (7):
  qlcnic: Support SR-IOV enable and disable
  qlcnic: SR-IOV VF probe
  qlcnic: Use shared interrupt vector for Tx and Rx
  qlcnic: VF-PF communication channel implementation
  qlcnic: Support VF-PF communication channel commands.
  qlcnic: Support atomic commands
  qlcnic: Bump up the version to 5.2.39
