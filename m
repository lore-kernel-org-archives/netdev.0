From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless: fix bogus maybe-uninitialized warning
Date: Wed, 09 Nov 2016 09:10:46 +0100
Message-ID: <1478679046.4345.1.camel@sipsolutions.net>
References: <20161024153918.2810634-1-arnd@arndb.de>
         <20161024153918.2810634-2-arnd@arndb.de> <87mvh9qwhi.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>,
        Jouni Malinen <j@w1.fi>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:53400 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752561AbcKIIKx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 03:10:53 -0500
In-Reply-To: <87mvh9qwhi.fsf@purkki.adurom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Ideally we prefer that drivers/net/wireless and net/wireless changes
> are
> split into different patches as they get applied to different trees.
> Johannes, is it ok if I take this change through my tree this time?

Sure, please do, thanks.

(I don't particularly care about the lib80211 stuff anyway)

johannes
