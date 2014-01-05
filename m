From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 0/6] phylib: cleanups
Date: Sun, 5 Jan 2014 03:15:29 +0300
Message-ID: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:48061 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754545AbaADXPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 18:15:30 -0500
Received: by mail-la0-f45.google.com with SMTP id eh20so9102804lab.32
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 15:15:29 -0800 (PST)
Received: from wasted.dev.rtsoft.ru (ppp91-76-87-5.pppoe.mtu-net.ru. [91.76.87.5])
        by mx.google.com with ESMTPSA id j1sm39493842lbl.10.2014.01.04.15.15.28
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Jan 2014 15:15:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   This patchset mainly cleans up the phylib's coding style but then also
removes some historically unused stuff. It's kind of follow up to the recent
Florian Fainelli's series which didn't finish checkpatch.pl complaint fixing.
The patchset is against DaveM's 'net-next.git' repo.

[1/8] phy: coding style fixes
[2/8] mdio_bus: coding style fixes
[3/8] <linux/phy.h>: coding style fixes
[4/8] phy: kill useless local variables
[5/8] phy: kill excess code
[6/8] phy: kill excess empty lines
[7/8] phylib: remove unused adjust_state() callback
[8/8] phylib: make phy_scan_fixups() static

WBR, Sergei
