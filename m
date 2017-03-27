From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH RFC v2 3/3] net: phy: allow EEE with SGMII interface modes
Date: Mon, 27 Mar 2017 23:47:28 +0100
Message-ID: <20170327224728.GU7909@n2100.armlinux.org.uk>
References: <20170327095826.GA2310@n2100.armlinux.org.uk>
 <E1csRQT-0004rM-Tq@rmk-PC.armlinux.org.uk>
 <5d3c3ce0-fabc-6b96-c7e9-c2e46ffe4d23@gmail.com>
 <20170327170019.GR7909@n2100.armlinux.org.uk>
 <9f523664-9479-26ca-e3f7-95453ed03560@gmail.com>
 <20170327194747.GS7909@n2100.armlinux.org.uk>
 <705b10f9-6a0c-3a35-ddff-04b75c6f80ec@gmail.com>
 <20170327201529.GT7909@n2100.armlinux.org.uk>
 <3bcc3380-6e59-06e3-9ebd-5450e89c90a2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:45204 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752502AbdC0Wrn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 18:47:43 -0400
Content-Disposition: inline
In-Reply-To: <3bcc3380-6e59-06e3-9ebd-5450e89c90a2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 03:42:57PM -0700, Florian Fainelli wrote:
> I think David will require you to resubmit this as an entire patch
> series and without an RFC tag. Do you want to hold off a bit to get
> build coverage or go ahead and target net-next right away?

I'd prefer to get build coverage first - there's no point in not using
the facilities that are available.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
