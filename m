From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH net-next-2.6 v5 0/5] sctp: Patch series
Date: Tue, 26 Apr 2011 00:22:58 +0900
Message-ID: <AAF0EA66-DF77-42AD-977C-EB9F52C305A1@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:52998 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754330Ab1DYPXA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 11:23:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Series of 5 patches to support auto_asconf and the other related functionalities that auto_asconf relies on. 

Cheers,
- Michio

[1/5] Add Auto-ASCONF support
[2/5] Add sysctl support for Auto-ASCONF
[3/5] Add socket option operation for Auto-ASCONF
[4/5] Add ADD/DEL ASCONF handling at the receiver
[5/5] Add ASCONF operation on the single-homed host
