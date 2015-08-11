From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] net: dsa: mv88e6xxx: support switchdev
 FDB objects
Date: Tue, 11 Aug 2015 10:38:17 -0700 (PDT)
Message-ID: <20150811.103817.787813230853567028.davem@davemloft.net>
References: <20150809.224822.1627697290087246344.davem@davemloft.net>
	<20150810133924.GA10802@ketchup.touchtunes.com>
	<1065657734.1253359.1439310306115.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, linux@roeck-us.net, andrew@lunn.ch,
	f.fainelli@gmail.com, sfeldma@gmail.com, jiri@resnulli.us
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753134AbbHKRiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 13:38:19 -0400
In-Reply-To: <1065657734.1253359.1439310306115.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 11 Aug 2015 12:25:06 -0400 (EDT)

> I can work on fixup patches to restore v3 changes on top of v2, but this
> won't fix the bisectability issue.
> 
> Instead of fixing individual portions, reverting the merge commit
> f1d5ca4: "Merge branch 'mv88e6xxx-switchdev-fdb'" would undo all the v2
> series at once, then v3 can be merged on top of it.
> 
> Can you consider this as an option?

Nothing will fix bisectability, so don't try.

Reverting an entire series when you have the fix available
already is excessive.

So as I have already asked you, send a relative fixup to clear
up this situation.

Thanks.
