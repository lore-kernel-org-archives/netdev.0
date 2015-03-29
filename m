From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/3] bnx2x: link and protection changes
Date: Sun, 29 Mar 2015 10:04:58 +0300
Message-ID: <1427612701-13469-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:47118 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750946AbbC2HFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 03:05:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series contains 2 small additions to link configuration,
as well as a safeguard against loading the device on a hardware at
a failed state.

Dave,

Please consider applying this series to `net-next'.

Thanks,
Yuval
-- 
1.8.3.1
