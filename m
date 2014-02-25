From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCHv2 1/5] ARM: tegra: remove obsolete gpio entries
Date: Tue, 25 Feb 2014 16:15:42 +0100
Message-ID: <1393341342.4170.9.camel@jlt4.sipsolutions.net>
References: <1393330950-7283-1-git-send-email-heikki.krogerus@linux.intel.com>
	 <1393330950-7283-2-git-send-email-heikki.krogerus@linux.intel.com>
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
	linux-tegra@vger.kernel.org,
	Thierry Reding <thierry.reding@gmail.com>
To: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393330950-7283-2-git-send-email-heikki.krogerus@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-02-25 at 14:22 +0200, Heikki Krogerus wrote:
> After moving to description based gpio interface in
> rfkill-gpio, the gpio numbers are not used any more.
> 
> Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
> ---
>  arch/arm/mach-tegra/board-paz00.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)

Hm, ok, I'm not sure I should take a tegra patch through the mac80211 ->
wireless -> networking trees. OTOH, I suppose that the second patch
depends on this. I can take it all I suppose, Thierry? Stephen?

johannes
