From: John Fastabend <john.fastabend@gmail.com>
Subject: [PATCH 0/2] ixgbe updates
Date: Sun, 23 Apr 2017 18:30:59 -0700
Message-ID: <20170424013004.8354.34893.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:37039 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163952AbdDXBbO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 21:31:14 -0400
Received: by mail-it0-f49.google.com with SMTP id x188so33526312itb.0
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 18:31:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff, Here are two patch updates for your tree. I merged in Alex's
build fix and Jakub's comments. Lightly tested xdp1 and xdp2.

---

John Fastabend (2):
      ixgbe: add XDP support for pass and drop actions
      ixgbe: add support for XDP_TX action


 0 files changed
