From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 0/3] cpmac fixes
Date: Sun, 7 Mar 2010 11:55:16 +0100
Message-ID: <201003071155.17553.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:63171 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab0CGKzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 05:55:24 -0500
Received: by bwz22 with SMTP id 22so2144929bwz.28
        for <netdev@vger.kernel.org>; Sun, 07 Mar 2010 02:55:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Here are 2 small cpmac fixes and a driver version bumping. Thanks!

Florian Fainelli (3):
  cpmac: fix the receiving of 802.1q frames
  cpmac: fallback to switch mode if no PHY chip found
  cpmac: bump version to 0.5.2
