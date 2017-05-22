From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Mon, 22 May 2017 23:02:15 +0200
Message-ID: <20170522210215.GQ29447@lunn.ch>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org,
        f.fainelli@gmail.com, David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40342 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933774AbdEVVCT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 17:02:19 -0400
Content-Disposition: inline
In-Reply-To: <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 2. I'm preparing a patch that adds a command-line parameter to at803x that
> makes this code conditional.

FYI:

A patch with a command line argument, i think you actually mean a
module argument, is very likely to be rejected.

  Andrew
