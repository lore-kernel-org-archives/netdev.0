From: <Woojung.Huh@microchip.com>
Subject: RE: DSA support for Micrel KSZ8895
Date: Wed, 23 Aug 2017 21:48:21 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B05FFF@CHN-SV-EXMX02.mchp-main.com>
References: <20170816075524.GA18532@amd> <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170823090941.GA27570@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Tristram.Ha@micrel.com>, <andrew@lunn.ch>
To: <pavel@ucw.cz>, <nathan.leigh.conrad@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170823090941.GA27570@amd>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel,

> > I'll forward your email to our support.
> > AFAIK, KSZ8895 has different register mapping from KSZ9477,
> > it will be more than ID changes in current driver.
> 
> More than ID changes, indeed. As layout is completely different, it
> looks like different source file will be needed for support.
> 
> I'm not nearly there; but I can ifconfig lanX up, already, and perform
> some pings.
> 
> Any ideas how to do the work in a way to minimize code duplication are
> welcome...

Which version do you use to create patch?
Getting error when applying patch to the latest net-next.

- Woojung
