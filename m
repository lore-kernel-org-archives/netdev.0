From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2009-12-29
Date: Tue, 29 Dec 2009 19:53:36 -0800 (PST)
Message-ID: <20091229.195336.193710512.davem@davemloft.net>
References: <20091229211223.GA6104@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49378
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751341AbZL3Dxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 22:53:34 -0500
In-Reply-To: <20091229211223.GA6104@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 29 Dec 2009 16:12:23 -0500

> Dave,
> 
> Here is a somewhat large batch of fixes intended for 2.6.33.  Most of
> them are simple, straightforward, and small.  There is one from Johannes
> that removes a lot of code, but the code it removes is unused and the
> patch quiets a lot of build SPAM.
> 
> This also includes the revert of a b43 patch that is causing some
> problems for people.  It does some (apparently unnecessary) alignment
> checking that causes some allocations to fail.
> 
> Please let me know if there are problems!

Pulled, thanks a lot John.
