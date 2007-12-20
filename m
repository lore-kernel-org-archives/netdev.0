From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 0/9][BNX2]: Add MSIX support.
Date: Thu, 20 Dec 2007 12:30:34 -0800
Message-ID: <1198182634.9163.26.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3541 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753331AbXLTTpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 14:45:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, this patchset lays the foundation for supporting multiple MSIX
IRQs.  Only 1 additional MSIX is added to handle TX separately from RX
at the moment.  Multiple TX and RX rings will be added in the future.
Please review for 2.6.25.  Thanks.

