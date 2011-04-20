From: Michio Honda <micchie@ht.sfc.keio.ac.jp>
Subject: [PATCH net-next-2.6 v4 0/5] sctp: Patch series
Date: Thu, 21 Apr 2011 04:24:11 +0900
Message-ID: <8AD20F69-97E7-4FCD-90A3-20E0E40D555F@ht.sfc.keio.ac.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.ht.sfc.keio.ac.jp ([133.27.170.14]:38841 "EHLO
	barracuda.ht.sfc.keio.ac.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751984Ab1DTTfe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 15:35:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Series of 5 patches to support auto_asconf and the other related functionalities that auto_asconf relies on. 

Cheers,
- Michio

[1/5] Add Auto-ASCONF support
[2/5] Add sysctl support for Auto-ASCONF
[3/5] Add socket option operation for Auto-ASCONF
[4/5] Add ASCONF operation on the single-homed host
[5/5] Add ADD/DEL ASCONF handling at the receiver

