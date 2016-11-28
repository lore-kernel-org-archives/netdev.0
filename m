From: Jerome Brunet <jbrunet@baylibre.com>
Subject: Re: [PATCH net-next v3 0/4] Documentation: net: phy: Improve
 documentation
Date: Mon, 28 Nov 2016 08:31:28 +0100
Message-ID: <1480318288.17538.155.camel@baylibre.com>
References: <20161128024515.13070-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, andrew@lunn.ch, sf84@laposte.net,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        timur@codeaurora.org
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f175.google.com ([209.85.210.175]:36860 "EHLO
        mail-wj0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750878AbcK1Hbc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 02:31:32 -0500
Received: by mail-wj0-f175.google.com with SMTP id qp4so107464267wjc.3
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 23:31:31 -0800 (PST)
In-Reply-To: <20161128024515.13070-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-11-27 at 18:45 -0800, Florian Fainelli wrote:
> Hi all,
> 
> This patch series addresses discussions and feedback that was
> recently received
> on the mailing-list in the area of: flow control/pause frames,
> interpretation of
> phy_interface_t and finally add some links to useful standards
> documents.
> 
> Changes in v3:
> 
> - add Timur's feedback into patch 3
> 
> Changes in v2:
> 
> - clarify a few things in the RGMII section, add a paragraph about
> common issues
>   with RGMII delay mismatches
> 

Thanks a lot Florian. This is really helping, especially the part about
RGMII delays.

Reviewed-by: Jerome Brunet <jbrunet@baylibre.com>

> Florian Fainelli (4):
>   Documentation: net: phy: remove description of function pointers
>   Documentation: net: phy: Add a paragraph about pause frames/flow
>     control
>   Documentation: net: phy: Add blurb about RGMII
>   Documentation: net: phy: Add links to several standards documents
> 
>  Documentation/networking/phy.txt | 140
> +++++++++++++++++++++++++++++----------
>  1 file changed, 105 insertions(+), 35 deletions(-)
> 
