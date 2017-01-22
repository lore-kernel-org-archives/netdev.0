From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/3] sh_eth: E-DMAC interrupt mask cleanups
Date: Sun, 22 Jan 2017 22:17:20 +0300
Message-ID: <1636105.gp4aQxGd5K@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:35990 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751179AbdAVTRZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 14:17:25 -0500
Received: by mail-lf0-f41.google.com with SMTP id z134so83449853lff.3
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 11:17:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   Here's a set of 3 patches against DaveM's 'net-next.git' repo. The main goal
of this set is to stop using the bare numbers for the E-DMAC interrupt masks.

[1/3] sh_eth: rename EESIPR bits
[2/3] sh_eth: add missing EESIPR bits
[3/3] sh_eth: stop using bare numbers for EESIPR values

MBR, Sergei
