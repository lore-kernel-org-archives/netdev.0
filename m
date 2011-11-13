From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v3 net-next 00/12] bnx2x series
Date: Sun, 13 Nov 2011 16:34:20 +0200
Message-ID: <1321194872-8276-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1435 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753781Ab1KMOeh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Nov 2011 09:34:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from v2:
    - Patch: "bnx2x: simplify definition of RX_SGE_MASK_LEN and use it"
      fixed according to Joe Perches <joe@perches.com> comment.
  
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
