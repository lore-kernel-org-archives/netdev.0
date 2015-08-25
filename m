From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 0/2] Documentation: dsa
Date: Tue, 25 Aug 2015 15:33:12 -0700
Message-ID: <1440541994-13662-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, sfeldma@gmail.com,
	linux@roeck-us.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35233 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752860AbbHYWfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 18:35:43 -0400
Received: by pacdd16 with SMTP id dd16so137597229pac.2
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 15:35:42 -0700 (PDT)
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
