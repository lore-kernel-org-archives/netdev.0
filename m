From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] Documentation: dsa
Date: Tue, 25 Aug 2015 06:50:40 -0700
Message-ID: <1440510642-15588-1-git-send-email-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
	sfeldma@gmail.com, linux@roeck-us.net, davem@davemloft.net,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:36144 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755058AbbHYNut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 09:50:49 -0400
Received: by obkg7 with SMTP id g7so142121964obk.3
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 06:50:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds some documentation about DSA as a subsystem as well
as the SF2 driver since it slightly diverges from your average DSA driver ;)

Florian Fainelli (2):
  Documentation: networking: add a DSA document
  Documentation: networking: dsa: Add Broadcom SF2 document

 Documentation/networking/dsa/bcm_sf2.txt | 113 ++++++
 Documentation/networking/dsa/dsa.txt     | 584 +++++++++++++++++++++++++++++++
 2 files changed, 697 insertions(+)
 create mode 100644 Documentation/networking/dsa/bcm_sf2.txt
 create mode 100644 Documentation/networking/dsa/dsa.txt

-- 
2.1.4
