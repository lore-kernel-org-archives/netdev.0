From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] Fix DMA channel misreporting for the Renesas Ethernet drivers
Date: Sun, 17 Jul 2016 16:06:24 +0300
Message-ID: <8592210.gMERdmUlCp@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:35580 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbcGQNG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 09:06:28 -0400
Received: by mail-lf0-f53.google.com with SMTP id f93so115478330lfi.2
        for <netdev@vger.kernel.org>; Sun, 17 Jul 2016 06:06:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   Here's a set of 2 patches against DaveM's 'net.git' repo fixing up the DMA
channel reporting by 'ifconfig'...

[1/2] ravb: fix DMA channel misreporting
[2/2] sh_eth: fix DMA channel misreporting

MBR, Sergei
