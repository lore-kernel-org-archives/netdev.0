From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH (net.git)] net: phy: at803x: disable by default the
 hibernation feature
Date: Tue, 25 Oct 2016 11:00:07 +0200
Message-ID: <20161025090007.GB21818@lunn.ch>
References: <1477384282-17878-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53446 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754577AbcJYJAL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Oct 2016 05:00:11 -0400
Content-Disposition: inline
In-Reply-To: <1477384282-17878-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> For example, while booting a Kernel the SYNP MAC (stmmac) fails
> to initialize own DMA engine if the phy entered in hibernation
> before.

Have you tried fixing stmmac instead?

     Andrew
