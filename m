From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 0/2] blackfin: Drop non-functional DSA code
Date: Tue, 19 Sep 2017 18:03:44 -0700
Message-ID: <20170920010346.16871-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, realmz6@gmail.com,
        adi-buildroot-devel@lists.sourceforge.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:37356 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751533AbdITBDw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 21:03:52 -0400
Received: by mail-qk0-f196.google.com with SMTP id r66so813826qke.4
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 18:03:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

I sent those many months ago in the hope that the bfin-linux people
would pick those patches but nobody seems to be responding, can you
queue those via net-next since this affects DSA?

Thanks!

Florian Fainelli (2):
  blackfin: tcm-bf518: Remove dsa.h inclusion
  blackfin: ezbrd: Remove non-functional DSA/KSZ8893M code

 arch/blackfin/mach-bf518/boards/ezbrd.c     | 47 -----------------------------
 arch/blackfin/mach-bf518/boards/tcm-bf518.c |  1 -
 2 files changed, 48 deletions(-)

-- 
2.11.0
