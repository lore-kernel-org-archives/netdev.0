From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 12 May 2008 20:52:24 -0700 (PDT)
Message-ID: <20080512.205224.12536510.davem@davemloft.net>
References: <1209936253.7304.10.camel@johannes.berg>
	<1209936745.7304.16.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35618
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753113AbYEMDwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 23:52:30 -0400
In-Reply-To: <1209936745.7304.16.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sun, 04 May 2008 23:32:25 +0200

> This assigns the netdev's needed_headroom/tailroom members
> to take advantage of pre-allocated space for 802.11 headers.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Now that I've applied the prerequisite patch, I've added this one
too and will do a lot of build testing just to make sure there
aren't any surprises.

Thanks!
