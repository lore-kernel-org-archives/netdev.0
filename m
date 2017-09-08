From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Fri, 8 Sep 2017 18:35:30 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B1C835@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170908091856.GB17738@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD41121E3D@CHN-SV-EXMX02.mchp-main.com>
 <20170908183227.GJ25219@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <pavel@ucw.cz>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <UNGLinuxDriver@microchip.com>
To: <andrew@lunn.ch>, <Tristram.Ha@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170908183227.GJ25219@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > > @@ -0,0 +1,2066 @@
> > > > +/*
> > > > + * Microchip KSZ8795 switch driver
> > > > + *
> > > > + * Copyright (C) 2017 Microchip Technology Inc.
> > > > + *	Tristram Ha <Tristram.Ha@microchip.com>
> > > > + *
> > > > + * Permission to use, copy, modify, and/or distribute this software for
> any
> > > > + * purpose with or without fee is hereby granted, provided that the
> above
> > > > + * copyright notice and this permission notice appear in all copies.
> > > > + *
> > > > + * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS
> ALL
> > > WARRANTIES
> > > > + * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
> WARRANTIES
> > > OF
> > > > + * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR
> BE
> > > LIABLE FOR
> > > > + * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR
> ANY
> > > DAMAGES
> > > > + * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
> WHETHER
> > > IN AN
> > > > + * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
> > > ARISING OUT OF
> > > > + * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
> SOFTWARE.
> > > > + */
> > >
> > > This is not exactly GPL, right? But tagging below says it is
> > > GPL. Please fix one.
> > >
> >
> > This boilerplate paragraph was copied from the KSZ9477 driver, although I
> did
> > wonder why this was used.
> 
> Hi Tristram
> 
> Please can you talk to your legal people and see if this can be
> replaced with the standard GPL text?
This should be replaced to GPL. These text copied from drivers/net/dsa/b53/*.
Will submit patches of drivers/net/dsa/microchip/*

- Woojung
