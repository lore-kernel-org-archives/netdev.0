From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 00:26:32 -0700 (PDT)
Message-ID: <20100416.002632.83844236.davem@davemloft.net>
References: <20100415.233334.242114544.davem@davemloft.net>
	<1271401007.16881.3762.camel@edumazet-laptop>
	<1271402283.16881.3791.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36331
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750752Ab0DPH02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 03:26:28 -0400
In-Reply-To: <1271402283.16881.3791.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Apr 2010 09:18:03 +0200

> Hmm, I wonder if its not an artifact of net-next-2.6 being a bit old
> (versus linux-2.6). I know scheduler guys did some tweaks.

I synced net-next-2.6 up with Linus's current tree just a day
or two ago when I pulled net-2.6 into net-next-2.6.
