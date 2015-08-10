From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v3 0/8] net: dsa: mv88e6xxx: support switchdev
 FDB objects
Date: Mon, 10 Aug 2015 10:40:36 -0400
Message-ID: <20150810144036.GB21682@ketchup.touchtunes.com>
References: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20150810141138.GH14271@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150810141138.GH14271@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On 15-08-10 16:11:38, Andrew Lunn wrote:
> On Mon, Aug 10, 2015 at 09:09:45AM -0400, Vivien Didelot wrote:
> > This patchset refactors the FDB management in the mv88e6xxx code and adds the
> > glue in DSA to use the switchdev FDB objects.
> 
> Hi Vivien
> 
> Thanks for reworking these patches. Now they are much smaller, they
> are much easier to review.
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks for your time and suggestions on this, indeed with the reworked
order, the diffs got smaller and more natural.

Regards,
-v
