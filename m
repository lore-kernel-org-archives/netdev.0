From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v2 net-next 00/12] bnx2x series
Date: Sun, 13 Nov 2011 14:47:17 +0200
Message-ID: <1321188449-5822-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2621 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752029Ab1KMMrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Nov 2011 07:47:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from v1:
    - Removed patch with pri_map module parameter.  


Hello Dave,

The series includes re-enabling FCoE and DCB for 578xx devices,
some improvements in licensing for cnic,   
DCBX propagation in MF modes, handling of fan failures,
removing napi struct from the stack and performs some code clean-ups. 

Please consider applying the series to net-next.

Thanks
Dmitry
