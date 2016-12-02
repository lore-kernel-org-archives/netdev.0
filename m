From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 0/3] UAPI export missing headers
Date: Fri,  2 Dec 2016 14:50:47 -0800
Message-ID: <20161202225050.30048-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, jhs@mojatatu.com,
        Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33584 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751506AbcLBW5p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 17:57:45 -0500
Received: by mail-pg0-f47.google.com with SMTP id 3so112167603pgd.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 14:57:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Files not being exported by make install headers

Stephen Hemminger (3):
  tc: export tunnel key file
  uapi: export tc_skbmod.h
  uapi: export nf_log.h

 include/uapi/linux/netfilter/Kbuild | 1 +
 include/uapi/linux/tc_act/Kbuild    | 2 ++
 2 files changed, 3 insertions(+)

-- 
2.10.2
