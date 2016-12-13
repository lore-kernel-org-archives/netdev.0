From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/6] USB support for Broadcom NSP SoC
Date: Mon, 12 Dec 2016 18:20:13 -0800
Message-ID: <79483fc3-5e91-a1f0-1dbf-1987682373e6@gmail.com>
References: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/09/2016 01:33 AM, Yendapally Reddy Dhananjaya Reddy wrote:
> This patch set contains the usb support for Broadcom NSP SoC.
> The usb phy is connected through mdio interface. The mdio interface
> can be used to access either internal phys or external phys using a
> multiplexer.
> 
> The first patch provides the documentation details for mdio-mux and
> second patch provides the documentation details for usb3 phy. The third
> patch contains the mdio-mux support and fourth patch contains the
> changes to the mdio bus driver.
> 
> The fifth patch provides the phy driver and sixth patch provides the
> enable method for usb.
> 
> This patch series has been tested on NSP bcm958625HR board.
> This patch series is based on v4.9.0-rc1 and is available from github-
> repo: https://github.com/Broadcom/cygnus-linux.git
> branch:nsp-usb-v1

Can you resubmit this patch series with the feedback from Andrew, Rob
and Scott addressed?

Thanks!
-- 
Florian
