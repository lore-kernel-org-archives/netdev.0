From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCHv3 0/5] net: rfkill: gpio: cleanup and a few new acpi ids
Date: Fri, 11 Apr 2014 09:26:13 +0200
Message-ID: <1397201173.4420.0.camel@jlt4.sipsolutions.net>
References: <1396360976-28657-1-git-send-email-heikki.krogerus@linux.intel.com>
	 <1396946275.5936.2.camel@jlt4.sipsolutions.net>
	 <20140409100147.GB3083@xps8300> <5345680F.3040903@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Chen-Yu Tsai <wens@csie.org>,
	Rhyland Klein <rklein@nvidia.com>,
	Marc Dietrich <marvin24@gmx.de>,
	Linus Walleij <linus.walleij@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Alexandre Courbot <gnurou@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-tegra@vger.kernel.org
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5345680F.3040903@wwwdotorg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-04-09 at 09:32 -0600, Stephen Warren wrote:

> > Stephen! Are you expecting any changes to board-paz00.c in this kernel
> > cycle? If not, I think it would be easiest if Johannes, you take the
> > whole set. What do you guys think?
> 
> I can't predict the future, but the chances are pretty slim - that file
> is pretty tiny and doesn't have much churn.
> 
> The best approach is to put this series in its own topic branch. Then,
> if any conflict does come up, I can simply merge the branch into the
> Tegra treee and apply the conflicting patches on top.

Ok, I'll do that. Shout now if you don't want these patches merged :)

johannes
