From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 0/3] Documentation: dsa: misc fixes
Date: Tue, 24 May 2016 21:26:38 -0700
Message-ID: <1464150401-2318-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, idosch@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34693 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbcEYE0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 00:26:48 -0400
Received: by mail-oi0-f68.google.com with SMTP id r64so8591083oie.1
        for <netdev@vger.kernel.org>; Tue, 24 May 2016 21:26:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Here are some miscelaneous documentation fixes for DSA, I targeted "net"
because these are not functional code changes, but still documentation fixes
per-se.

Changes in v2:

- reword what the port_vlan_filtering is about based on feedback from Vivien and Ido

Florian Fainelli (3):
  Documentation: networking: dsa: Remove poll_link description
  Documentation: networking: dsa: Remove priv_size description
  Documentation: networking: dsa: Describe port_vlan_filtering

 Documentation/networking/dsa/dsa.txt | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

-- 
2.7.4
