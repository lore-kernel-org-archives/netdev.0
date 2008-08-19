From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2008-08-18
Date: Mon, 18 Aug 2008 21:16:32 -0700 (PDT)
Message-ID: <20080818.211632.251536898.davem@davemloft.net>
References: <20080817185605.GC30679@tuxdriver.com>
	<20080817.151251.204370966.davem@davemloft.net>
	<20080818151551.GA5524@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57157
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751107AbYHSEQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 00:16:33 -0400
In-Reply-To: <20080818151551.GA5524@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 18 Aug 2008 11:15:51 -0400

> (Revision 2, commit references in changelogs augmented w/ subject text.)
> 
> Here is the latest round of wireless fixes for 2.6.27.  The silliest one
> is the one from Adrian Bunk, which applies the gcc-related fix to ath9k
> again because there were two identical pieces of code to fix -- I guess
> I didn't get the joke *facepalm*...
> 
> I don't think there is anything else remarkable, although I think we fix
> a couple of the current regressions on LKML.

Pulled thanks John.

Assuming nothing shows up in my build testing I'll push this out
to kernel.org shortly.

Thanks again!
