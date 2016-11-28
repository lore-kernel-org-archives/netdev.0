From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 0/4] Documentation: net: phy: Improve documentation
Date: Sun, 27 Nov 2016 18:45:11 -0800
Message-ID: <20161128024515.13070-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, sf84@laposte.net,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        timur@codeaurora.org, jbrunet@baylibre.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33700 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754084AbcK1CpU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 21:45:20 -0500
Received: by mail-oi0-f66.google.com with SMTP id f201so11799041oib.0
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 18:45:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series addresses discussions and feedback that was recently received
on the mailing-list in the area of: flow control/pause frames, interpretation of
phy_interface_t and finally add some links to useful standards documents.

Changes in v3:

- add Timur's feedback into patch 3

Changes in v2:

- clarify a few things in the RGMII section, add a paragraph about common issues
  with RGMII delay mismatches

Florian Fainelli (4):
  Documentation: net: phy: remove description of function pointers
  Documentation: net: phy: Add a paragraph about pause frames/flow
    control
  Documentation: net: phy: Add blurb about RGMII
  Documentation: net: phy: Add links to several standards documents

 Documentation/networking/phy.txt | 140 +++++++++++++++++++++++++++++----------
 1 file changed, 105 insertions(+), 35 deletions(-)

-- 
2.9.3
