From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/4] Documentation: net: phy: Improve documentation
Date: Sun, 27 Nov 2016 10:44:45 -0800
Message-ID: <20161127184449.12351-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, sf84@laposte.net,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        timur@codeaurora.org, jbrunet@baylibre.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36322 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752187AbcK0Sox (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 13:44:53 -0500
Received: by mail-oi0-f66.google.com with SMTP id u15so10872223oie.3
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 10:44:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series addresses discussions and feedback that was recently received
on the mailing-list in the area of: flow control/pause frames, interpretation of
phy_interface_t and finally add some links to useful standards documents.

Changes in v2:

- clarify a few things in the RGMII section, add a paragraph about common issues
  with RGMII delay mismatches

Florian Fainelli (4):
  Documentation: net: phy: remove description of function pointers
  Documentation: net: phy: Add a paragraph about pause frames/flow
    control
  Documentation: net: phy: Add blurb about RGMII
  Documentation: net: phy: Add links to several standards documents

 Documentation/networking/phy.txt | 139 +++++++++++++++++++++++++++++----------
 1 file changed, 104 insertions(+), 35 deletions(-)

-- 
2.9.3
