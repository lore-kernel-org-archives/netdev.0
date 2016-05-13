From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] Kill unneeded local variables in the LXT PHY driver
Date: Sat, 14 May 2016 02:07:05 +0300
Message-ID: <15412071.hrgkzMpf1A@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:36206 "EHLO
	mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502AbcEMXHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 19:07:09 -0400
Received: by mail-lf0-f52.google.com with SMTP id u64so95374800lff.3
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 16:07:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

    [Resending with the correct subject. Sorry about that :-/]

   Here's the set of 2 patches against DaveM's 'net-next.git' repo. We save
several LoCs on the unneeded local variables....

[1/2] lxt: simplify lxt97[01]_config_intr()
[2/2] lxt: simplify lxt970_config_init()

MBR, Sergei
