From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/2] qed{,e}: Add vlan filtering offload
Date: Thu, 18 Feb 2016 17:00:38 +0200
Message-ID: <1455807640-28165-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:61618 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1425895AbcBRPBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 10:01:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds vlan filtering offload to qede.
First patch introduces small additional infrastructure needed in
qed to support it, while second contains the main bulk of driver changes.

Dave,

Please consider applying this series to `net-next'.

Thanks,
Yuval
-- 
1.8.3.1
