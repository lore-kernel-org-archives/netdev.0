From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: Re: [PATCHv3 0/5] net: rfkill: gpio: cleanup and a few new acpi ids
Date: Wed, 9 Apr 2014 13:01:47 +0300
Message-ID: <20140409100147.GB3083@xps8300>
References: <1396360976-28657-1-git-send-email-heikki.krogerus@linux.intel.com>
 <1396946275.5936.2.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chen-Yu Tsai <wens@csie.org>, Rhyland Klein <rklein@nvidia.com>,
	Marc Dietrich <marvin24@gmx.de>,
	Linus Walleij <linus.walleij@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Alexandre Courbot <gnurou@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-tegra@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	Stephen Warren <swarren@wwwdotorg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1396946275.5936.2.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Apr 08, 2014 at 10:37:55AM +0200, Johannes Berg wrote:
> On Tue, 2014-04-01 at 17:02 +0300, Heikki Krogerus wrote:
> > I hope this one is OK with everyone.
> 
> It's fine with me. Are you expecting me to pick up any of these patches,
> or do you want them to go through some other tree? Either way is fine
> with me, but the first patch looks like something I probably shouldn't
> be taking.

The second patch depends on it.

Stephen! Are you expecting any changes to board-paz00.c in this kernel
cycle? If not, I think it would be easiest if Johannes, you take the
whole set. What do you guys think?


Thanks,

-- 
heikki
