From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next] Ethtool: Add Altera Triple Speed Ethernet Support
Date: Thu, 24 Apr 2014 17:07:25 -0500
Message-ID: <1398377246-7083-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: netdev@vger.kernel.org, ben@decadent.org.uk, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:65515 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756465AbaDXWLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 18:11:49 -0400
Received: by mail-pa0-f50.google.com with SMTP id rd3so2405114pab.37
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 15:11:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds Altera Triple Speed Ethernet support to dump registers
from Ethtool. 

If you find this patch acceptable, please consider this for inclusion. 

Thank you,

Vince

Vince Bridgers (1):
  Ethtool: Add Altera Triple Speed Ethernet Register Dump Routine

 Makefile.am |    2 +-
 ethtool.c   |    1 +
 internal.h  |    5 +++
 tse.c       |  111 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 118 insertions(+), 1 deletion(-)
 create mode 100644 tse.c

-- 
1.7.9.5
