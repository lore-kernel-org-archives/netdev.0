From: David Miller <davem@davemloft.net>
Subject: Re: Please pull 'upstream-davem' branch of wireless-2.6
Date: Tue, 17 Jul 2007 20:17:16 -0700 (PDT)
Message-ID: <20070717.201716.112622844.davem@davemloft.net>
References: <20070718021607.GB26907@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59444
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753103AbXGRDRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 23:17:17 -0400
In-Reply-To: <20070718021607.GB26907@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 17 Jul 2007 22:16:07 -0400

> A few more for 2.6.23...individual patches available here:
> 
>   http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-davem

What about this warning which I reported to you right after the last
merge?  Did this get fixed?

net/mac80211/ieee80211.c:4989: warning: comparison of distinct pointer types lacks a cast

Please fix that up first, then I'll pull from your tree.
