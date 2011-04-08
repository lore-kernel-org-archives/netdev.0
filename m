From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH net-next-2.6 v3 0/3] sctp: Patch series
Date: Fri, 8 Apr 2011 14:18:30 +0900
Message-ID: <DF0CDFCF-8559-495A-9C9E-60997E7DE0F2@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:53939 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751176Ab1DHFSc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 01:18:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Series of 5 patches to support auto_asconf and the other related functionalities that auto_asconf relies on. 

Cheers,
- Michio

[1/3] Add Auto-ASCONF support
[2/3] Add ASCONF operation on the single-homed host
[3/3] Add a valid address list in association local
