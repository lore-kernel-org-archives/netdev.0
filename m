From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH ethtool] Ethtool: Add Altera Triple Speed Ethernet Support
Date: Thu,  8 May 2014 13:15:18 -0500
Message-ID: <1399572919-32198-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: bwh@kernel.org, netdev@vger.kernel.org, ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:33913 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbaEHSTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 14:19:39 -0400
Received: by mail-pd0-f178.google.com with SMTP id r10so2651098pdi.9
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 11:19:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds Altera Triple Speed Ethernet support to dump registers
from Ethtool. 

If you find this patch acceptable, please consider this for inclusion. 

Thank you,

Vince

Vince Bridgers (1):
  Ethtool: Add Altera Triple Speed Ethernet Support

 Makefile.am |    2 +-
 ethtool.c   |    1 +
 internal.h  |    4 +++
 tse.c       |  106 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 112 insertions(+), 1 deletion(-)
 create mode 100644 tse.c

-- 
1.7.9.5
