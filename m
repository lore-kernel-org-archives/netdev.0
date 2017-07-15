From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 1/2] dt-bindings: net: Add bindings for National
 Instruments XGE netdev
Date: Sat, 15 Jul 2017 21:48:32 +0200
Message-ID: <20170715194832.GB28217@lunn.ch>
References: <1500065326-26182-1-git-send-email-mdf@kernel.org>
 <20170715183745.GA28217@lunn.ch>
 <20170715184653.GA28599@tyrael.ni.corp.natinst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net,
        mark.rutland@arm.com, robh+dt@kernel.org
To: Moritz Fischer <mdf@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170715184653.GA28599@tyrael.ni.corp.natinst.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > +		ethernet_phy1: ethernet-phy@4 {
> > > +			compatible = "ethernet-phy-ieee802.3-c45";
> > > +			reg = <4>;
> > > +			devices = <0xa>;
> > > +		};
> > 
> > Since you don't fully implement c45, does this example actually work?
> 
> Yeah, I've tested this continuously. But for v3 I anyways implmented c45
> writes.

Hi Moritz

Just out of interest, what PHY are you using?

    Andrew
