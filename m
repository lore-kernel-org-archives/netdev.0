From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/4] qed*: [mostly] Ethtool RSS configuration
Date: Sun, 10 Apr 2016 12:42:58 +0300
Message-ID: <1460281382-13656-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:37912 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752083AbcDJJnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 05:43:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of the content [code-wise] in this series is for allowing various
RSS-related configuration via ethtool.

In addition, this also removed an unnecessary versioning scheme between
the drivers and bump the driver version.

Dave,

Please consider applying this to `net-next'.

Thanks,
Yuval
