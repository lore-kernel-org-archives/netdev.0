From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/2] Documentation: dsa
Date: Tue, 25 Aug 2015 10:40:33 -0700
Message-ID: <1440524435-8129-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, sfeldma@gmail.com,
	linux@roeck-us.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33954 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402AbbHYRoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 13:44:22 -0400
Received: by pabzx8 with SMTP id zx8so40175774pab.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 10:44:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds some documentation about DSA as a subsystem as well
as the SF2 driver since it slightly diverges from your average DSA driver ;)

Florian Fainelli (2):
  Documentation: networking: add a DSA document
  Documentation: networking: dsa: Add Broadcom SF2 document

 Documentation/networking/dsa/bcm_sf2.txt | 113 ++++++
 Documentation/networking/dsa/dsa.txt     | 615 +++++++++++++++++++++++++++++++
 2 files changed, 728 insertions(+)
 create mode 100644 Documentation/networking/dsa/bcm_sf2.txt
 create mode 100644 Documentation/networking/dsa/dsa.txt

-- 
2.1.0
