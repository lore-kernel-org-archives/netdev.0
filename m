From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCHv2 0/5] net: rfkill: gpio: cleanup and a few new acpi ids
Date: Tue, 25 Feb 2014 16:11:08 +0100
Message-ID: <1393341068.4170.7.camel@jlt4.sipsolutions.net>
References: <1393330950-7283-1-git-send-email-heikki.krogerus@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Chen-Yu Tsai <wens@csie.org>,
	Rhyland Klein <rklein@nvidia.com>,
	Marc Dietrich <marvin24@gmx.de>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Alexandre Courbot <gnurou@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-tegra@vger.kernel.org
To: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393330950-7283-1-git-send-email-heikki.krogerus@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-02-25 at 14:22 +0200, Heikki Krogerus wrote:

> I was waiting for the DT support from Chen-Yu before sending these,
> but decided it makes no difference when I send them. I'm dropping the
> con ID in the second patch because Dan noticed the warning, but of
> course it will mean the "gpios" property can be used with DT.
> 
> The two last patches just add ACPI IDs for some new Baytrail based
> boards.

Do these patches have any dependencies, or should I just add them to the
mac80211-next tree (since I don't keep a separate rfkill tree)?

Or does anyone else want to take them? In that case, it's all fine with
me, I'm really just nominally the rfkill maintainer and have no idea
about these patches... :)

johannes
