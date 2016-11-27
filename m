From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] Documentation: net: phy: Improve documentation
Date: Sat, 26 Nov 2016 22:01:29 -0800
Message-ID: <20161127060133.10357-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, sf84@laposte.net,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        timur@codeaurora.org, jbrunet@baylibre.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:32988 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751033AbcK0GCK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 01:02:10 -0500
Received: by mail-oi0-f68.google.com with SMTP id f201so9695691oib.0
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 22:01:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series addresses discussions and feedback that was recently received
on the mailing-list in the area of: flow control/pause frames, interpretation of
phy_interface_t and finally add some links to useful standards documents.

Florian Fainelli (4):
  Documentation: net: phy: remove description of function pointers
  Documentation: net: phy: Add a paragraph about pause frames/flow
    control
  Documentation: net: phy: Add blurb about RGMII
  Documentation: net: phy: Add links to several standards documents

 Documentation/networking/phy.txt | 119 +++++++++++++++++++++++++++------------
 1 file changed, 84 insertions(+), 35 deletions(-)

-- 
2.9.3
