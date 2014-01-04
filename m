From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/6] phylib: cleanups
Date: Sat, 4 Jan 2014 04:13:06 +0300
Message-ID: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:41262 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807AbaADANG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 19:13:06 -0500
Received: by mail-lb0-f176.google.com with SMTP id l4so8524789lbv.35
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 16:13:04 -0800 (PST)
Received: from wasted.dev.rtsoft.ru (ppp91-76-83-104.pppoe.mtu-net.ru. [91.76.83.104])
        by mx.google.com with ESMTPSA id h11sm37471656lbg.8.2014.01.03.16.13.02
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Jan 2014 16:13:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   This patchset mainly cleans up the phylib's coding style but then also
removes some historically unused stuff.

[1/6] phy: coding style fixes
[2/6] mdio_bus: coding style fixes
[3/6] phy: kill useless local variables
[4/6] phy: kill excess code
[5/6] phylib: remove unused adjust_state callback
[6/6] phylib: make phy_scan_fixups() static

WBR, Sergei
