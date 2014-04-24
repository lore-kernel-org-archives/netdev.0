From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 0/3] bnx2x: SRIOV bug fixes
Date: Thu, 24 Apr 2014 19:29:51 +0300
Message-ID: <1398356994-30759-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34450 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752895AbaDXQ37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 12:29:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains 3 SRIOV bug fixes, 2 of which are regressions starting
with commit 2dc33bbc "bnx2x: Remove the sriov VFOP mechanism".

Please consider applying these patches to `net'.

Thanks,
Yuval Mintz
