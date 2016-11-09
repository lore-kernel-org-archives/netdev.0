From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] wireless: fix bogus maybe-uninitialized warning
Date: Wed, 09 Nov 2016 16:06:32 +0100
Message-ID: <2654653.cBclyC49py@wuerfel>
References: <20161024153918.2810634-1-arnd@arndb.de> <87mvh9qwhi.fsf@purkki.adurom.net> <1478679046.4345.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Stanislav Yakovlev <stas.yakovlev@gmail.com>,
        Jouni Malinen <j@w1.fi>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478679046.4345.1.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, November 9, 2016 9:10:46 AM CET Johannes Berg wrote:
> 
> > Ideally we prefer that drivers/net/wireless and net/wireless changes
> > are
> > split into different patches as they get applied to different trees.

Ok, good to know. I had split out the drivers/staging changes, but
wasn't sure about the granularity you'd want here.

> > Johannes, is it ok if I take this change through my tree this time?

> Sure, please do, thanks.
> 
> (I don't particularly care about the lib80211 stuff anyway)

Thanks!

	Arnd
