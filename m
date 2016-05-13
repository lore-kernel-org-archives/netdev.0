From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] Don't return NULL from get_phy_device() anymore
Date: Sat, 14 May 2016 02:05:17 +0300
Message-ID: <7078673.lTHka36u4G@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33962 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559AbcEMXFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 19:05:22 -0400
Received: by mail-lf0-f47.google.com with SMTP id m64so94897128lfd.1
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 16:05:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   Here's the set of 2 patches against DaveM's 'net-next.git' repo. We save
several LoCs on the unneeded local variables....

[1/2] lxt: simplify lxt97[01]_config_intr()
[2/2] lxt: simplify lxt970_config_init()

MBR, Sergei
