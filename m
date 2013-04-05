From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 0/4] netxen_nic: Bug fixes and enhancement
Date: Fri,  5 Apr 2013 08:36:39 -0400
Message-ID: <1365165403-18348-1-git-send-email-manish.chopra@qlogic.com>
Cc: netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:31916 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1161612Ab3DEM76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Apr 2013 08:59:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply this patch series to net-next.

Thanks,
Manish

Manish Chopra (4):
  netxen_nic: Fix mismatched board type error
  netxen_nic: Log driver version with firmware version
  netxen_nic: Add module parameters support to switch interrupts
  netxen_nic: Bump up the version to 4.0.81
