From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: Re: [PATCH net-next v2 0/4] Documentation: net: phy: Improve documentation
Date: Sun, 27 Nov 2016 21:32:38 +0100
Message-ID: <CAFBinCAuTnRvfEpAYxjJP5a=vQHjB3UWPxKvKjB8B60-bUtwrQ@mail.gmail.com>
References: <20161127184449.12351-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
        sf84@laposte.net, mans@mansr.com, alexandre.torgue@st.com,
        peppe.cavallaro@st.com, timur@codeaurora.org, jbrunet@baylibre.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33861 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752661AbcK0UdM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 15:33:12 -0500
Received: by mail-wm0-f67.google.com with SMTP id g23so15890060wme.1
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 12:33:00 -0800 (PST)
In-Reply-To: <20161127184449.12351-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 27, 2016 at 7:44 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Hi all,
>
> This patch series addresses discussions and feedback that was recently received
> on the mailing-list in the area of: flow control/pause frames, interpretation of
> phy_interface_t and finally add some links to useful standards documents.
>
> Changes in v2:
>
> - clarify a few things in the RGMII section, add a paragraph about common issues
>   with RGMII delay mismatches
Reviewed-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>

Thanks a lot Florian, this will definitely help others in the future!

> Florian Fainelli (4):
>   Documentation: net: phy: remove description of function pointers
>   Documentation: net: phy: Add a paragraph about pause frames/flow
>     control
>   Documentation: net: phy: Add blurb about RGMII
>   Documentation: net: phy: Add links to several standards documents
>
>  Documentation/networking/phy.txt | 139 +++++++++++++++++++++++++++++----------
>  1 file changed, 104 insertions(+), 35 deletions(-)
>
> --
> 2.9.3
>
