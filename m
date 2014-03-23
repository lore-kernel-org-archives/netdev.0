From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/5] bnx2x: SR-IOV patch series
Date: Sun, 23 Mar 2014 18:12:22 +0200
Message-ID: <1395591147-26350-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:43344 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751699AbaCWQNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 12:13:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

(With the exception of the first patch) This series contains IOV-related
patches, where the main changes are related to the driver's IOV-support
backbone - it adds a new workqueue for IOV related tasks and removes the vfop
mechanism from the driver.

Please consider applying this series to `net-next'.

Thanks,
Yuval Mintz
