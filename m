From: David Miller <davem@davemloft.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Sat, 23 Feb 2008 20:02:02 -0800 (PST)
Message-ID: <20080223.200202.255773165.davem@davemloft.net>
References: <1203589042.17534.145.camel@johannes.berg>
	<1203616486.7181.269.camel@localhost>
	<47BDBC23.5080007@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, johannes@sipsolutions.net,
	harvey.harrison@gmail.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58102
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752419AbYBXEBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 23:01:21 -0500
In-Reply-To: <47BDBC23.5080007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 21 Feb 2008 19:00:03 +0100

> And adds back the overhead of two completely unnecessary
> function calls to the VLAN fastpath. How about just
> stopping this idiocy and reverting the appropriate patches
> to bring back MAC_FMT and use it where appropriate?

Agreed, I'll do that.
