From: Peter Robinson <pbrobinson@gmail.com>
Subject: Tighten some of the net/phy SoC dependencies
Date: Sun,  5 Mar 2017 12:14:32 +0000
Message-ID: <20170305121434.22674-1-pbrobinson@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35324 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752444AbdCEMOk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 07:14:40 -0500
Received: by mail-wm0-f54.google.com with SMTP id v186so44897401wmd.0
        for <netdev@vger.kernel.org>; Sun, 05 Mar 2017 04:14:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A pair of small Kconfig patches to tightend some of the PHY MDIO 
dependencies one the SoCs, fairly self explanatory.

Peter
