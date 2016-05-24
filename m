From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/3] Documentation: dsa: misc fixes
Date: Mon, 23 May 2016 21:32:14 -0700
Message-ID: <1464064337-8743-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:36485 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbcEXEc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 00:32:29 -0400
Received: by mail-oi0-f65.google.com with SMTP id x130so1290986oia.3
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 21:32:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Here are some miscelaneous documentation fixes for DSA, I targeted "net"
because these are not functional code changes, but still documentation fixes
per-se.

Florian Fainelli (3):
  Documentation: networking: dsa: Remove poll_link description
  Documentation: networking: dsa: Remove priv_size description
  Documentation: networking: dsa: Describe port_vlan_filtering

 Documentation/networking/dsa/dsa.txt | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

-- 
2.7.4
