From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 5/6] net: dsa: mv88e6060: add register defines header file
Date: Tue, 10 Nov 2015 09:39:32 -0500
Message-ID: <20151110143931.GA7731@ketchup.mtl.sfl>
References: <5641F04A.9060303@baylibre.com>
 <20151110142550.GB29568@ketchup.mtl.sfl>
 <20151110143050.GA23891@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Armstrong <narmstrong@baylibre.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151110143050.GA23891@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Nov. Tuesday 10 (46) 03:30 PM, Andrew Lunn wrote:
> On Tue, Nov 10, 2015 at 09:25:51AM -0500, Vivien Didelot wrote:
> > Hi Neil,
> > 
> > On Nov. Tuesday 10 (46) 02:25 PM, Neil Armstrong wrote:
> > > To align with the mv88e6xxx code, add a similar header file
> > > with all the register defines.
> > > The file is based on the mv88e6xxx header for coherency.
> > > 
> > > Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> > 
> > In the RFC patchset, Andrew mentioned that there is not that much things in
> > common with mv88e6xxx, so I don't really see a value to add a separate header
> > file. Would that make sense to you guys to add the defines directly in
> > mv88e6060.c and squash that in the last patch?
> 
> It is personal taste, but i think there are enough defines that having
> a separate header file is useful. For < 10 i would agree with Vivien,
> but with ~100, i prefer a header file. 

OK. So please fix the copyright owner of this new file then and we're good :-)

Thanks,
-v
