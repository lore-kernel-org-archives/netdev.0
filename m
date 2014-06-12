From: Yuval Mintz <yuval.mintz@qlogic.com>
Subject: [PATCH v2 net 0/4] bnx2x: Bug fixes patch series
Date: Thu, 12 Jun 2014 07:55:28 +0300
Message-ID: <1402548932-30520-1-git-send-email-yuval.mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariel.elior@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:52530 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750787AbaFLEzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 00:55:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series contains various bug fixes - 2 link related fixes,
one sriov-related issue and an additional fix for a theoretical bug
on new boards.

Please consider applying these patches to `net'.

Changes from V1:
----------------
 - Patch 1 has been semantically revised.

Thanks,
Yuval Mintz
