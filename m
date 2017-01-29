From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 0/3] sh_eth: E-DMAC interrupt mask cleanups
Date: Sun, 29 Jan 2017 15:06:39 +0300
Message-ID: <3387005.NzsGXf10rT@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:33303 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdA2MII (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 07:08:08 -0500
Received: by mail-lf0-f49.google.com with SMTP id x1so95543682lff.0
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 04:06:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   Here's a set of 3 patches against DaveM's 'net-next.git' repo. The main goal
of this set is to stop using the bare numbers for the E-DMAC interrupt masks.

[1/3] sh_eth: rename EESIPR bits
[2/3] sh_eth: add missing EESIPR bits
[3/3] sh_eth: stop using bare numbers for EESIPR values

MBR, Sergei
