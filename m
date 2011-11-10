From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 00/13] bnx2x series
Date: Thu, 10 Nov 2011 17:14:01 +0200
Message-ID: <1320938054-31288-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3995 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932644Ab1KJPO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Nov 2011 10:14:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

The series includes re-enabling FCoE and DCB for 578xx devices,
some improvements in licensing for cnic,   
DCBX propagation in MF modes, handling of fan failures,
removing napi struct from the stack, introduces pri_map
module parameter and performs some code clean-ups. 

Please consider applying the series to net-next.

Thanks
Dmitry
