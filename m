From: Stefan Eichenberger <eichest@gmail.com>
Subject: [PATCH net-next 0/2] Add support for the MV88e6097
Date: Wed, 23 Nov 2016 18:55:44 +0100
Message-ID: <20161123175546.31416-1-stefan.eichenberger@netmodule.com>
Cc: netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:35300 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932464AbcKWR4p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 12:56:45 -0500
Received: by mail-wj0-f195.google.com with SMTP id f8so1583081wje.2
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 09:56:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset will add support for the MV88E6097 DSA switch and enable
EDSA on MV88E6097 family devices.

Stefan Eichenberger (2):
  net: dsa: mv88e6xxx: add MV88E6097 switch
  net: dsa: mv88e6xxx: enable EDSA on mv88e6097

 drivers/net/dsa/mv88e6xxx/chip.c      | 26 ++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  5 ++++-
 2 files changed, 30 insertions(+), 1 deletion(-)

-- 
2.9.3
