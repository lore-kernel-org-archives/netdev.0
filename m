From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: Re: [PATCH v3 2/6] net: rfkill: gpio: convert to descriptor-based
 GPIO interface
Date: Mon, 23 Dec 2013 12:54:20 +0200
Message-ID: <20131223105420.GP8621@intel.com>
References: <1385460350-17543-1-git-send-email-mika.westerberg@linux.intel.com>
 <1385460350-17543-3-git-send-email-mika.westerberg@linux.intel.com>
 <CACRpkdb03X_Z7amX-vAVX8KboeCo3ia6oqv8KW79WY=nZXV7wQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-netdev@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Chris Ball <cjb@laptop.org>, Rhyland Klein <rklein@nvidia.com>,
	Adrian Hunter <adrian.hunter@intel.com>,
	Alexandre Courbot <acourbot@nvidia.com>,
	Mathias Nyman <mathias.nyman@linux.intel.com>,
	Rob Landley <rob@landley.net>,
	Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Thierry Reding <thierry.reding@gmail.com>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Linus Walleij <linus.walleij@linaro.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-gpio-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACRpkdb03X_Z7amX-vAVX8KboeCo3ia6oqv8KW79WY=nZXV7wQ@mail.gmail.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 11, 2013 at 01:00:18PM +0100, Linus Walleij wrote:
> On Tue, Nov 26, 2013 at 11:05 AM, Mika Westerberg
> <mika.westerberg@linux.intel.com> wrote:
> 
> > From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
> >
> > Convert to the safer gpiod_* family of API functions.
> >
> > Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
> > Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
> > Tested-by: Stephen Warren <swarren@nvidia.com>

Johannes B, David M,

Are you fine with this patch? If yes, could you ack it so that we could get
it merged for 3.14.

Thanks!

Here's a link to this series:

https://lkml.org/lkml/2013/11/26/104
