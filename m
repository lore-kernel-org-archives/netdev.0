From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH v4 0/7] Ammasso 1100 iWARP Driver
Date: Thu, 03 Aug 2006 16:07:23 -0500
Message-ID: <20060803210723.16572.34829.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:44186 "EHLO
	dell3.ogc.int") by vger.kernel.org with ESMTP id S1751376AbWHCVHY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 17:07:24 -0400
To: rdreier@cisco.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Roland, here is the updated Ammasso 1100 iWARP Driver.

----

This patchset implements the iWARP provider driver for the Ammasso
1100 RNIC.  It is dependent on the "iWARP Core Support" patch set.
The patchset consists of 7 patches:

        1 - Low-level device interface and native stack support
        2 - Work request definitions
        3 - Provider interface
        4 - Memory management
        5 - User mode message queue implementation      
        6 - Verbs queue implementation
        7 - Kconfig and Makefile

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
