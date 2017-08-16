From: <Woojung.Huh@microchip.com>
Subject: RE: DSA support for Micrel KSZ8895
Date: Wed, 16 Aug 2017 14:25:36 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
References: <20170816075524.GA18532@amd> <20170816140451.GA13006@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Tristram.Ha@micrel.com>, <andrew@lunn.ch>
To: <pavel@denx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170816140451.GA13006@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Hi!
> >
> > I've got hardware with KSZ8895, and I'd like to use switch ports as
> > separate ethernet cards. I believe that means DSA support.
> >
> > And there are even patches available from microchip... unfortunately
> > they are in strange form and for v3.18.
> >
> >
> http://www.microchip.com/SWLibraryWeb/product.aspx?product=KSZ8895
> %20Software%20Linux%203.18
> >
> > Is there newer version of the driver available somewhere? Is the
> > driver good starting point, or should I start with something else?
> 
> Hi Pavel
> 
> Woojung is the expert here. His DSA driver for the 9477 is a nice
> clean driver.
> 
> Have you compared the 8895 to the 9477. Are they similar? Could the
> existing 9477 be extended to support the 8895?
> 
> 	 Andrew

Hi Pavel,

I'll forward your email to our support.
AFAIK, KSZ8895 has different register mapping from KSZ9477,
it will be more than ID changes in current driver.

Thanks.
Woojung
