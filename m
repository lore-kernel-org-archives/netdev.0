From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCHv2 0/5] net: rfkill: gpio: cleanup and a few new acpi ids
Date: Tue, 25 Feb 2014 09:59:07 -0800
Message-ID: <D8A6682F-CC21-4428-AFA3-C50FBA8ED1F7@holtmann.org>
References: <1393330950-7283-1-git-send-email-heikki.krogerus@linux.intel.com> <1393341068.4170.7.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Rhyland Klein <rklein-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
	Marc Dietrich <marvin24-Mmb7MZpHnFY@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org Wireless"
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393341068.4170.7.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Johannes,

>> I was waiting for the DT support from Chen-Yu before sending these,
>> but decided it makes no difference when I send them. I'm dropping the
>> con ID in the second patch because Dan noticed the warning, but of
>> course it will mean the "gpios" property can be used with DT.
>> 
>> The two last patches just add ACPI IDs for some new Baytrail based
>> boards.
> 
> Do these patches have any dependencies, or should I just add them to the
> mac80211-next tree (since I don't keep a separate rfkill tree)?
> 
> Or does anyone else want to take them? In that case, it's all fine with
> me, I'm really just nominally the rfkill maintainer and have no idea
> about these patches... :)

someone has to take them. So I say go for it.

Regards

Marcel
