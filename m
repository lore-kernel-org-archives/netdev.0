From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: phy: add extension of phy-mode for
 XLGMII
Date: Fri, 9 Dec 2016 17:39:05 +0100
Message-ID: <20161209163905.GG9923@lunn.ch>
References: <cover.1481075763.git.jiedeng@synopsys.com>
 <6d4a65c5488364cdaec72eb22e742aa7e94dfebb.1481075763.git.jiedeng@synopsys.com>
 <30c8257d-9ad9-71bf-a969-77dbe37bd800@gmail.com>
 <d42cbc77-1409-281a-161f-cf9c85443369@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        CARLOS.PALMINHA@synopsys.com, lars.persson@axis.com,
        thomas.lendacky@amd.com
To: Jie Deng <Jie.Deng1@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <d42cbc77-1409-281a-161f-cf9c85443369@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 09, 2016 at 01:19:07PM +0800, Jie Deng wrote:
> 
> 
> On 2016/12/9 6:15, Florian Fainelli wrote:
> > On 12/06/2016 07:57 PM, Jie Deng wrote:
> >> This patch adds phy-mode support for Synopsys XLGMAC
> > The functional changes look good, but I would like to see some
> > description of what the XL part stands for here.
> >
> > While you are modifying this, do you also mind submitting a Device Tree
> > specification change:
> >
> > https://www.devicetree.org/specifications/
> >
> > Thanks!
> Thank you for the information.
> 
> Currenlty, the XLGMAC is a new IP from Synopsys.

I think Florian wants to know about the IEEE standard or what ever
which defines what the phy-mode XLGMAC is, in the same way there are
standards for RGMII, SGMII, etc.

	  Andrew
