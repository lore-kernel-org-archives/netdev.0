From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Mon, 08 Sep 2008 21:15:48 -0700 (PDT)
Message-ID: <20080908.211548.216826057.davem@davemloft.net>
References: <20080909025525.GB25148@hostap.isc.org>
	<20080908.204323.04156464.davem@davemloft.net>
	<20080909040525.GA26151@hostap.isc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jouni.malinen@atheros.com, alex.williamson@hp.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: j@w1.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45623
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751842AbYIIEPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:15:54 -0400
In-Reply-To: <20080909040525.GA26151@hostap.isc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jouni Malinen <j@w1.fi>
Date: Mon, 8 Sep 2008 21:05:25 -0700

> Would people be fine with extending wireless_send_event() with new
> event types that use fixed sized fields or is someone going to be
> interesting in providing a better replacement for this
> functionality?

I thought this was the idea behind nl80211?  To be a new netlink
interface for wireless, one that actually is designed correctly
from the start and thus can avoid all of these problems.

