From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [ethtool PATCH v1 0/2] ethtool: add support for 1000BaseX and missing 10G link mode
Date: Sun, 28 Aug 2016 23:56:48 -0700
Message-ID: <1472453810-47177-1-git-send-email-vidya@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, dustin@cumulusnetworks.com
To: linville@tuxdriver.com, netdev@vger.kernel.org, bwh@kernel.org,
        davem@davemloft.net, decot@googlers.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36216 "EHLO
        mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756426AbcH2G47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 02:56:59 -0400
Received: by mail-pa0-f45.google.com with SMTP id ci2so6093889pad.3
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 23:56:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

This patchset enhances ethtool link mode bitmap to include
missing interface modes for 1G/10G speeds

Vidya Sagar Ravipati (2):
  ethtool-copy.h:sync with net
  ethtool: add support for 1000BaseX and missing 10G link mode

 ethtool-copy.h | 11 +++++++++--
 ethtool.c      | 19 +++++++++++++++++++
 2 files changed, 28 insertions(+), 2 deletions(-)

-- 
2.1.4
