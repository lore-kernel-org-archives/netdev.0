From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net/wireless: CFG80211_WEXT_EXPORT requires wireless
 extensions
Date: Mon, 13 Apr 2015 10:09:20 +0200
Message-ID: <1428912560.2355.0.camel@sipsolutions.net>
References: <2303996.H1mYPouv05@wuerfel>
	 <1428733011.2139.1.camel@sipsolutions.net> <4904912.VjuX4Pm71s@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4904912.VjuX4Pm71s@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-04-11 at 22:41 +0200, Arnd Bergmann wrote:

> As Paul commented, it does work, and I have of course checked that my
> patch fixes the problem without introducing other build failures.

:-)
Ok, I learned something. I'm always careful with "select" because it has
some corner cases.

Anyway, my other patch is in net-next now, so it'll be fixed in a tree
near you soon :)

johannes
