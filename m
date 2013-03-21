From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/3] sh_eth: probe/remove code cleanup/improvement
Date: Thu, 21 Mar 2013 23:36:16 +0300
Message-ID: <201303212336.16714.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:43288 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536Ab3CUTe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 15:34:57 -0400
Received: by mail-la0-f42.google.com with SMTP id fe20so5928972lab.15
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 12:34:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   Here is the series of 3 patches doing some cleanup and improvements to the
driver's probe/remove code paths.

[1/3] sh_eth: use PIR_* bits
[2/3] sh_eth: kill unneeded typecast in sh_eth_drv_probe()
[3/3] sh_eth: use managed device API

   All patches are against the recent David Miller's net-next.git to which he
has just helpfully merged my 2 recent fixes which are the base of the cleanups.

WBR, Sergei
