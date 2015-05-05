From: Okash Khawaja <okash.khawaja@gmail.com>
Subject: [PATCH 0/2] adm8211 patches
Date: Tue, 5 May 2015 23:39:40 +0100
Message-ID: <20150505223940.GA3546@bytefire-computer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:38025 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbbEEWju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 18:39:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches include two changes:

1. Code cleanup around a switch-case statement
2. Bug fix for the possible PCI cache line sizes

Okash Khawaja (2):
  adm8211: fix checkpatch errors for indentation and new line
  adm8211: fix the possible pci cache line sizes inside switch-case

 drivers/net/wireless/adm8211.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

-- 
1.9.1
