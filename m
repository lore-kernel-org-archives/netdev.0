From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/4] net: dsa: mv88e6xxx: Allow mv88e6xxx_smi_init() to
 be used at address 0x1
Date: Mon, 19 Dec 2016 16:07:59 +0100
Message-ID: <20161219150759.GG10048@lunn.ch>
References: <20161219141610.30934-1-romain.perier@free-electrons.com>
 <20161219141610.30934-2-romain.perier@free-electrons.com>
 <20161219143848.GA10048@lunn.ch>
 <292d4f15-c58b-3565-26ec-98a025b6adb3@free-electrons.com>
 <20161219150008.GE10048@lunn.ch>
 <CABHmqqDqhJa6N=Ayu-GFNyp4g90dXzTje6o8qfCEP2DacCFWdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Romain Perier <romain.perier@free-electrons.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Kumar Gala <galak@codeaurora.org>,
        linux-arm-kernel@lists.infradead.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>
To: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58729 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751652AbcLSPIF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Dec 2016 10:08:05 -0500
Content-Disposition: inline
In-Reply-To: <CABHmqqDqhJa6N=Ayu-GFNyp4g90dXzTje6o8qfCEP2DacCFWdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2016 at 04:04:32PM +0100, Volodymyr Bendiuga wrote:
> Hi Andrew,
> 
> No, it did not get accepted. Or at least I did not see
> David accepting it. Let me know if I should resubmit it.

Hi Volodymyr

Please do resend it. Probably netdev will reopen sometime after the
25th.

Don't forget to include the reviewed-by i gave.

Thanks

	Andrew
