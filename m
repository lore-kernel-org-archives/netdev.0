From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 3/7] net: ethernet: bgmac: move BCMA MDIO Phy code into a
 separate file
Date: Wed, 29 Jun 2016 22:15:49 +0200
Message-ID: <20160629201549.GG7480@lunn.ch>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
 <1467142484-11161-4-git-send-email-jon.mason@broadcom.com>
 <20160629141324.GA24194@lunn.ch>
 <577414F0.3060609@gmail.com>
 <20160629184618.GC7480@lunn.ch>
 <CAC3K-4p9z5pmxmga_ssZ_VA6RNFD5dTTCvms=KJMWvZDVxtNqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Rafa?? Mi??ecki <zajec5@gmail.com>, davem@davemloft.net,
	Hauke Mehrtens <hauke@hauke-m.de>,
	BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jon Mason <jon.mason@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAC3K-4p9z5pmxmga_ssZ_VA6RNFD5dTTCvms=KJMWvZDVxtNqw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 29, 2016 at 04:08:20PM -0400, Jon Mason wrote:
> On Wed, Jun 29, 2016 at 2:46 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> > On Wed, Jun 29, 2016 at 11:35:28AM -0700, Florian Fainelli wrote:
> >> On 06/29/2016 07:13 AM, Andrew Lunn wrote:
> >> > Hi Jon
> >> >
> >> > I know you are just refactoring code, but at some point it would be
> >> > good to take a closer look at this MDIO bus driver.
> >
> >> And, to re-iterate all of your points are valid, but this is premature
> >
> > We agree then :-)
> >
> >    Andrew
> 
> I also agree with all of your points, but hope this is not something
> that would prevent this patch series from being acceptable.

No, it is acceptable as is.

However, it would be nice the clean up the mess, especially if you are
planning on using this code with new platforms, not just legacy stuff
which is bit rotting.

      Andrew
