From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 0/2] bnx2x: small fixes
Date: Mon, 10 Aug 2015 12:49:34 +0300
Message-ID: <1439200176-17662-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:8727 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753302AbbHJJto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 05:49:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds 2 small fixes, one to error flows during memory release
and the other to flash writes via ethtool API.

Dave,

Please consider applying this series to `net'.

Thanks,
Yuval
-- 
1.8.3.1
