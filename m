From: Stefan Eichenberger <eichest@gmail.com>
Subject: [PATCH net-next 0/2] Fix support for the MV88E6097
Date: Fri, 25 Nov 2016 09:27:20 +0100
Message-ID: <20161125082722.1184-1-stefan.eichenberger@netmodule.com>
Cc: netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36924 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbcKYI1w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 03:27:52 -0500
Received: by mail-wm0-f52.google.com with SMTP id t79so83603547wmt.0
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 00:27:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes the following two issues for the MV88E6097:
- Add missing definition of g1_irqs
- Add missing comment

Stefan Eichenberger (2):
  net: dsa: mv88e6xxx: add g1_irqs definition for MV88E6097
  net: dsa: mv88e6xxx: add missing comment for MV88E6097

 drivers/net/dsa/mv88e6xxx/chip.c | 2 ++
 1 file changed, 2 insertions(+)

-- 
2.9.3
