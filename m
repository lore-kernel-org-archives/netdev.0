From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/6] qede/qed: Implement various ethtool operations
Date: Mon, 30 Nov 2015 12:25:00 +0200
Message-ID: <1448879106-12321-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Sudarsana.Kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:13590 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752481AbbK3K0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 05:26:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds several new ethtool operations to qede:
  - {get, set}_channels
  - {get, set}_ringparam
  - set_phys_id
  - nway_reset
  - {get, set}_pauseparam
As well as extending the qed APIs to support these commands.

Dave, please consider applying this series to `net-next'.

Thanks,
Yuval
