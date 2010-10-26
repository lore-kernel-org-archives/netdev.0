From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-10-26
Date: Tue, 26 Oct 2010 11:32:29 -0700 (PDT)
Message-ID: <20101026.113229.02280866.davem@davemloft.net>
References: <20101026181515.GD2446@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46734
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756909Ab0JZScG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 14:32:06 -0400
In-Reply-To: <20101026181515.GD2446@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 26 Oct 2010 14:15:16 -0400

> Here are some fixes intended for 2.6.37.  Highlights are some carl9170
> fixes, a fix/cleanup for the earlier wl1251 move, various ath9k fixes,
> a mac80211 fix relating to IBSS station expiry and a cfg80211 fix
> related to processing country IEs.  One of the ath9k patches looks big,
> but it is just changing a table of register initialization values in
> order to correct a number of issues.  The associated changelogs are
> reasonably descriptive of the issues involved.
> 
> Also included is a patch from Tejun as part of his work to remove
> flush_scheduled_work().  I noticed you already included a similar
> patch from Tejun, so I figured this was acceptable as well.

Pulled, thanks John.
