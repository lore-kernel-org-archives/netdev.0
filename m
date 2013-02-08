From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Fri, 08 Feb 2013 16:57:48 -0500 (EST)
Message-ID: <20130208.165748.1764406121592777701.davem@davemloft.net>
References: <20130208.151713.1708597749091717933.davem@davemloft.net>
	<CA+55aFx81-GGEEXx+MqJvwJsDoBMMqSN80=J8LmN-Ufu4+kKcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, romieu@fr.zoreil.com,
	nic_swsd@realtek.com
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFx81-GGEEXx+MqJvwJsDoBMMqSN80=J8LmN-Ufu4+kKcw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 9 Feb 2013 08:00:39 +1100

> However, there's still the r8169 regressions (see the emails with the
> subject "regression: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0
> timed out"). It's bisected, and a revert is reported to fix things.
> It's not in this pull request. Comments?

We're waiting for Hayes Wang, the author and the person most
knowledgable about those changes, to respond.

If I don't hear anything by next Weds I'll simply revert the
suspect changes.
