From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: pull-request: mac80211-next 2015-05-29
Date: Mon, 01 Jun 2015 09:11:38 +0200
Message-ID: <1433142698.3505.1.camel@sipsolutions.net>
References: <1432898714.2104.15.camel@sipsolutions.net>
	 <20150531.173534.725322474667007103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:56406 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750959AbbFAHLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2015 03:11:42 -0400
In-Reply-To: <20150531.173534.725322474667007103.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-05-31 at 17:35 -0700, David Miller wrote:
> Pulled, but there was a small conflict in include/net/mac80211.h which seemed
> trivially resolvable.  Take a look and send me a fixup if I got it wrong,
> thanks.

Looks good - it seems I managed to apply two different docbook fixes to
the two different trees ... Talk about being confused :)

johannes
